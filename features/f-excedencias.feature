Feature: f-excedencias · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-F01 Anónimo no crea excedencias
    Given url baseUrl + '/rest/v1/player_leaves'
    And header apikey = anonKey
    * def reqBody = {"profile_id":"00000000-0000-0000-0000-000000000000","start_date":"2030-01-01","end_date":"2030-01-10"}
    And request reqBody
    When method post
    * def ev = ({ request: { method: 'POST', url: baseUrl + '/rest/v1/player_leaves', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  Scenario: TC-F02 Anónimo no lee excedencias
    Given url baseUrl + '/rest/v1/player_leaves?select=id'
    And header apikey = anonKey
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/player_leaves?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-F03 Bloqueado no lee excedencias
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.blocked
    Given url baseUrl + '/rest/v1/player_leaves?select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/player_leaves?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-F04 Jugador FOE consulta excedencias
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/player_leaves?select=id,status'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/player_leaves?select=id,status', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"isArray":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-F05 Jugador FOE no aprueba excedencias ajenas
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/player_leaves?profile_id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    * def reqBody = {"status":"approved"}
    And request reqBody
    When method patch
    * def ev = ({ request: { method: 'PATCH', url: baseUrl + '/rest/v1/player_leaves?profile_id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

