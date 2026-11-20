Feature: f-excedencias · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-API07 Anónimo no crea excedencias
    Given url baseUrl + '/rest/v1/player_leaves'
    And header apikey = anonKey
    And request {"profile_id":"00000000-0000-0000-0000-000000000000","start_date":"2030-01-01","end_date":"2030-01-10"}
    When method post
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  Scenario: TC-API39 Anónimo no lee excedencias
    Given url baseUrl + '/rest/v1/player_leaves?select=id'
    And header apikey = anonKey
    When method get
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API40 Bloqueado no lee excedencias
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.blocked
    Given url baseUrl + '/rest/v1/player_leaves?select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API41 Jugador FOE consulta excedencias
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/player_leaves?select=id,status'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"isArray":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API42 Jugador FOE no aprueba excedencias ajenas
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/player_leaves?profile_id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    And request {"status":"approved"}
    When method patch
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

