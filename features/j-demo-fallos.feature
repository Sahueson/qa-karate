Feature: j-demo-fallos · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-J01 Un anónimo ve la lista de partidas (requisito inexistente)
    Given url baseUrl + '/rest/v1/events?select=id'
    And header apikey = anonKey
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/events?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"nonEmpty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-J02 El jugador MAD crea una partida en FOE (requisito inexistente)
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/events'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    * def reqBody = {"title":"QA demo","squad":"FOE","date":"2030-01-01","hour":"10:00","field":"x","event_type":"normal"}
    And request reqBody
    When method post
    * def ev = ({ request: { method: 'POST', url: baseUrl + '/rest/v1/events', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[201]}, responseStatus, response)
    Then match err == ''

  Scenario: TC-J03 El endpoint de estadísticas de partidas responde 200
    Given url baseUrl + '/rest/v1/event_stats?select=id'
    And header apikey = anonKey
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/event_stats?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200]}, responseStatus, response)
    Then match err == ''

