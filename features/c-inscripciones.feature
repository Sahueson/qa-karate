Feature: c-inscripciones · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-C01 Anónimo no ve inscripciones (RLS)
    Given url baseUrl + '/rest/v1/event_registrations?select=id'
    And header apikey = anonKey
    When method get
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  Scenario: TC-C02 Anónimo no se inscribe
    Given url baseUrl + '/rest/v1/event_registrations'
    And header apikey = anonKey
    And request {"event_id":"00000000-0000-0000-0000-000000000000","profile_id":"00000000-0000-0000-0000-000000000000","team":"x","role":"y"}
    When method post
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-C03 Usuario sin equipo no ve inscripciones
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.sinequipo
    Given url baseUrl + '/rest/v1/event_registrations?select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-C04 Bloqueado no ve inscripciones
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.blocked
    Given url baseUrl + '/rest/v1/event_registrations?select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-C05 Jugador MAD solo ve inscripciones de partidas de MAD
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/event_registrations?select=id,events(squad)'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"eachEq":{"path":"events.squad","value":"MAD Irregulars"}}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-C06 Jugador FOE no cancela inscripciones ajenas
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/event_registrations?profile_id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    When method delete
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

