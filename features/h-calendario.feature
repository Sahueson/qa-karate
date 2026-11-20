Feature: h-calendario · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-API48 Anónimo no ve fechas sin partida
    Given url baseUrl + '/rest/v1/team_blackouts?select=id'
    And header apikey = anonKey
    When method get
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  Scenario: TC-API49 Anónimo no crea fechas sin partida
    Given url baseUrl + '/rest/v1/team_blackouts'
    And header apikey = anonKey
    And request {"squad":"MAD Irregulars","start_date":"2030-01-01","end_date":"2030-01-02"}
    When method post
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API50 Jugador MAD consulta fechas sin partida
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/team_blackouts?select=id,squad'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"isArray":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API51 Jugador MAD no crea fechas sin partida
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/team_blackouts'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And request {"squad":"MAD Irregulars","start_date":"2030-01-01","end_date":"2030-01-02"}
    When method post
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API52 Jugador MAD no borra fechas sin partida
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/team_blackouts?id=not.is.null&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    When method delete
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

