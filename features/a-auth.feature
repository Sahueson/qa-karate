Feature: a-auth · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-API10 Sin apikey se rechaza
    Given url baseUrl + '/rest/v1/events?select=id'
    When method get
    * def err = check({"status":[401]}, responseStatus, response)
    Then match err == ''

  Scenario: TC-API11 Login con contraseña incorrecta falla
    Given url baseUrl + '/auth/v1/token?grant_type=password'
    And header apikey = anonKey
    And request {"email":"qa.player.mad@example.com","password":"contraseña-incorrecta"}
    When method post
    * def err = check({"status":[400],"errorCode":"invalid_credentials"}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API12 Login correcto devuelve token
    * if (!qaPassword) karate.abort()
    Given url baseUrl + '/auth/v1/token?grant_type=password'
    And header apikey = anonKey
    And request {"email":"qa.player.mad@example.com","password":'#(qaPassword)'}
    When method post
    * def err = check({"status":[200],"token":true}, responseStatus, response)
    Then match err == ''

  Scenario: TC-API05 Anónimo no lee perfiles
    Given url baseUrl + '/rest/v1/profiles?select=id'
    And header apikey = anonKey
    When method get
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API18 Jugador MAD lee su propio perfil
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/profiles?select=nickname,app_role&id=eq.' + (typeof session !== 'undefined' ? session.uid : '') + ''
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"hasValue":{"path":"0.app_role","value":"player"}}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API19 Bloqueado lee su perfil y figura bloqueado
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.blocked
    Given url baseUrl + '/rest/v1/profiles?select=nickname,is_blocked&id=eq.' + (typeof session !== 'undefined' ? session.uid : '') + ''
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"hasValue":{"path":"0.is_blocked","value":true}}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API20 Usuario sin equipo no ve partidas
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.sinequipo
    Given url baseUrl + '/rest/v1/events?select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API21 Un jugador no se asciende a super admin
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/profiles?id=eq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=app_role,is_super_admin'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    And request {"app_role":"super_admin","is_super_admin":true}
    When method patch
    * def err = check({"notEscalated":true}, responseStatus, response)
    Then match err == ''

