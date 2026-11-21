Feature: a-auth · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-A01 Sin apikey se rechaza
    Given url baseUrl + '/rest/v1/events?select=id'
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/events?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[401]}, responseStatus, response)
    Then match err == ''

  Scenario: TC-A02 Login con contraseña incorrecta falla
    Given url baseUrl + '/auth/v1/token?grant_type=password'
    And header apikey = anonKey
    * def reqBody = {"email":"qa.player.mad@example.com","password":"contraseña-incorrecta"}
    And request reqBody
    When method post
    * def ev = ({ request: { method: 'POST', url: baseUrl + '/auth/v1/token?grant_type=password', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[400],"errorCode":"invalid_credentials"}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-A03 Login correcto devuelve token
    * if (!qaPassword) karate.abort()
    Given url baseUrl + '/auth/v1/token?grant_type=password'
    And header apikey = anonKey
    * def reqBody = {"email":"qa.player.mad@example.com","password":'#(qaPassword)'}
    And request reqBody
    When method post
    * def ev = ({ request: { method: 'POST', url: baseUrl + '/auth/v1/token?grant_type=password', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"token":true}, responseStatus, response)
    Then match err == ''

  Scenario: TC-A04 Anónimo no lee perfiles
    Given url baseUrl + '/rest/v1/profiles?select=id'
    And header apikey = anonKey
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/profiles?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-A05 Jugador MAD lee su propio perfil
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/profiles?select=nickname,app_role&id=eq.' + (typeof session !== 'undefined' ? session.uid : '') + ''
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/profiles?select=nickname,app_role&id=eq.' + (typeof session !== 'undefined' ? session.uid : '') + '', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"hasValue":{"path":"0.app_role","value":"player"}}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-A06 Bloqueado lee su perfil y figura bloqueado
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.blocked
    Given url baseUrl + '/rest/v1/profiles?select=nickname,is_blocked&id=eq.' + (typeof session !== 'undefined' ? session.uid : '') + ''
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/profiles?select=nickname,is_blocked&id=eq.' + (typeof session !== 'undefined' ? session.uid : '') + '', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"hasValue":{"path":"0.is_blocked","value":true}}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-A07 Usuario sin equipo no ve partidas
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.sinequipo
    Given url baseUrl + '/rest/v1/events?select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/events?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-A08 Un jugador no se asciende a super admin
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/profiles?id=eq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=app_role,is_super_admin'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    * def reqBody = {"app_role":"super_admin","is_super_admin":true}
    And request reqBody
    When method patch
    * def ev = ({ request: { method: 'PATCH', url: baseUrl + '/rest/v1/profiles?id=eq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=app_role,is_super_admin', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"notEscalated":true}, responseStatus, response)
    Then match err == ''

