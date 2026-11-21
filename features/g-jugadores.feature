Feature: g-jugadores · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  @auth
  Scenario: TC-G01 Super admin ve perfiles de ambos equipos
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.superadmin
    Given url baseUrl + '/rest/v1/profiles?select=squad'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/profiles?select=squad', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"hasSquads":["MAD Irregulars","FOE"]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-G02 Jugador MAD solo ve perfiles de su unidad
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/profiles?select=nickname,squad'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/profiles?select=nickname,squad', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"nonEmpty":true,"eachEq":{"path":"squad","value":"MAD Irregulars"}}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-G03 Jugador FOE no ve perfiles de MAD
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/profiles?select=nickname&nickname=eq.QA%20Jugador%20MAD'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/profiles?select=nickname&nickname=eq.QA%20Jugador%20MAD', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-G04 Jugador MAD no cambia el rol de otros
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/profiles?id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    * def reqBody = {"app_role":"admin"}
    And request reqBody
    When method patch
    * def ev = ({ request: { method: 'PATCH', url: baseUrl + '/rest/v1/profiles?id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-G05 Jugador MAD no bloquea a otros
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/profiles?id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    * def reqBody = {"is_blocked":true}
    And request reqBody
    When method patch
    * def ev = ({ request: { method: 'PATCH', url: baseUrl + '/rest/v1/profiles?id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

