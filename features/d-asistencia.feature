Feature: d-asistencia · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-API29 Anónimo no marca asistencia
    Given url baseUrl + '/rest/v1/event_registrations?attended=eq.false'
    And header apikey = anonKey
    And request {"attended":true}
    When method patch
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API30 Jugador FOE no marca asistencia ajena
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/event_registrations?profile_id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    And request {"attended":true}
    When method patch
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API31 Jugador MAD no marca asistencia ajena
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/event_registrations?profile_id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    And request {"attended":true}
    When method patch
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-API32 Super admin consulta la asistencia
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.superadmin
    Given url baseUrl + '/rest/v1/event_registrations?select=id,attended'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def err = check({"status":[200],"isArray":true}, responseStatus, response)
    Then match err == ''

