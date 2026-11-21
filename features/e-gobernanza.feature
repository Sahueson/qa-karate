Feature: e-gobernanza · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-E01 Anónimo no ve votaciones FOE (RLS)
    Given url baseUrl + '/rest/v1/foe_polls?select=id'
    And header apikey = anonKey
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/foe_polls?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  Scenario: TC-E02 Anónimo no ve faltas FOE (RLS)
    Given url baseUrl + '/rest/v1/foe_infractions?select=id'
    And header apikey = anonKey
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/foe_infractions?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-E03 Jugador MAD no ve votaciones FOE
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/foe_polls?select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/foe_polls?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-E04 Jugador FOE sin cargo no ve votaciones de la Junta
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/foe_polls?select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/foe_polls?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-E05 Admin FOE de la Junta ve las votaciones
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.admin_foe
    Given url baseUrl + '/rest/v1/foe_polls?select=id,board'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/foe_polls?select=id,board', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"nonEmpty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-E06 Jugador MAD no ve faltas FOE
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/foe_infractions?select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/foe_infractions?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-E07 Jugador FOE no crea votaciones
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/foe_polls'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    * def reqBody = {"board":"junta_directiva","title":"QA intrusa","topic_type":"general","options":[]}
    And request reqBody
    When method post
    * def ev = ({ request: { method: 'POST', url: baseUrl + '/rest/v1/foe_polls', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-E08 Jugador FOE no borra votaciones
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_foe
    Given url baseUrl + '/rest/v1/foe_polls?id=not.is.null&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    When method delete
    * def ev = ({ request: { method: 'DELETE', url: baseUrl + '/rest/v1/foe_polls?id=not.is.null&select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

