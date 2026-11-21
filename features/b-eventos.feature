Feature: b-eventos · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-B01 Anónimo no ve partidas (RLS)
    Given url baseUrl + '/rest/v1/events?select=id'
    And header apikey = anonKey
    When method get
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  Scenario: TC-B02 Anónimo no crea partidas
    Given url baseUrl + '/rest/v1/events'
    And header apikey = anonKey
    And request {"title":"x","date":"2030-01-01","hour":"10:00","field":"x"}
    When method post
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  Scenario: TC-B03 Anónimo no borra partidas
    Given url baseUrl + '/rest/v1/events?id=not.is.null'
    And header apikey = anonKey
    When method delete
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-B04 Jugador MAD solo ve partidas de su equipo
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/events?select=id,squad'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"nonEmpty":true,"eachEq":{"path":"squad","value":"MAD Irregulars"}}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-B05 Jugador FOE no ve partidas de MAD
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/events?select=id,squad'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"nonEmpty":true,"eachEq":{"path":"squad","value":"FOE"}}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-B06 Bloqueado no ve ninguna partida
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.blocked
    Given url baseUrl + '/rest/v1/events?select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-B07 Jugador MAD no crea partidas en FOE
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/events'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And request {"title":"QA intrusa","squad":"FOE","date":"2030-01-01","hour":"10:00","field":"x","event_type":"normal"}
    When method post
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-B08 Super admin ve partidas de ambos equipos
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.superadmin
    Given url baseUrl + '/rest/v1/events?select=id,squad'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"hasSquads":["MAD Irregulars","FOE"]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-B09 Jugador FOE no edita partidas
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/events?squad=eq.FOE&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    And request {"title":"hackeada"}
    When method patch
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-B10 Admin MAD no borra partidas de FOE
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.admin_mad
    Given url baseUrl + '/rest/v1/events?squad=eq.FOE&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    When method delete
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

