Feature: d-asistencia · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-D01 Anónimo no marca asistencia
    Given url baseUrl + '/rest/v1/event_registrations?attended=eq.false'
    And header apikey = anonKey
    * def reqBody = {"attended":true}
    And request reqBody
    When method patch
    * def ev = ({ request: { method: 'PATCH', url: baseUrl + '/rest/v1/event_registrations?attended=eq.false', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-D02 Jugador FOE no marca asistencia ajena
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/event_registrations?profile_id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    * def reqBody = {"attended":true}
    And request reqBody
    When method patch
    * def ev = ({ request: { method: 'PATCH', url: baseUrl + '/rest/v1/event_registrations?profile_id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-D03 Jugador MAD no marca asistencia ajena
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/event_registrations?profile_id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    * def reqBody = {"attended":true}
    And request reqBody
    When method patch
    * def ev = ({ request: { method: 'PATCH', url: baseUrl + '/rest/v1/event_registrations?profile_id=neq.' + (typeof session !== 'undefined' ? session.uid : '') + '&select=id', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-D04 Super admin consulta la asistencia
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.superadmin
    Given url baseUrl + '/rest/v1/event_registrations?select=id,attended'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/event_registrations?select=id,attended', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"isArray":true}, responseStatus, response)
    Then match err == ''

