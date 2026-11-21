Feature: h-calendario · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-H01 Anónimo no ve fechas sin partida
    Given url baseUrl + '/rest/v1/team_blackouts?select=id'
    And header apikey = anonKey
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/team_blackouts?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  Scenario: TC-H02 Anónimo no crea fechas sin partida
    Given url baseUrl + '/rest/v1/team_blackouts'
    And header apikey = anonKey
    * def reqBody = {"squad":"MAD Irregulars","start_date":"2030-01-01","end_date":"2030-01-02"}
    And request reqBody
    When method post
    * def ev = ({ request: { method: 'POST', url: baseUrl + '/rest/v1/team_blackouts', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-H03 Jugador MAD consulta fechas sin partida
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/team_blackouts?select=id,squad'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/team_blackouts?select=id,squad', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"isArray":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-H04 Jugador MAD no crea fechas sin partida
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/team_blackouts'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    * def reqBody = {"squad":"MAD Irregulars","start_date":"2030-01-01","end_date":"2030-01-02"}
    And request reqBody
    When method post
    * def ev = ({ request: { method: 'POST', url: baseUrl + '/rest/v1/team_blackouts', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-H05 Jugador MAD no borra fechas sin partida
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/team_blackouts?id=not.is.null&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    When method delete
    * def ev = ({ request: { method: 'DELETE', url: baseUrl + '/rest/v1/team_blackouts?id=not.is.null&select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

