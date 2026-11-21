Feature: i-normas · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-I01 Anónimo no lee documentos del equipo
    Given url baseUrl + '/rest/v1/team_documents?select=id'
    And header apikey = anonKey
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/team_documents?select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"empty":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-I02 Jugador MAD consulta los documentos de su equipo
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/team_documents?select=id,squad'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/team_documents?select=id,squad', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"isArray":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-I03 Jugador MAD no sube documentos
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/team_documents'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    * def reqBody = {"squad":"MAD Irregulars","category":"bof","title":"QA","file_url":"x","file_path":"x"}
    And request reqBody
    When method post
    * def ev = ({ request: { method: 'POST', url: baseUrl + '/rest/v1/team_documents', body: reqBody }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[401,403]}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-I04 Jugador MAD no borra documentos
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/team_documents?id=not.is.null&select=id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And header Prefer = 'return=representation'
    When method delete
    * def ev = ({ request: { method: 'DELETE', url: baseUrl + '/rest/v1/team_documents?id=not.is.null&select=id', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

  Scenario: TC-I05 El bucket de normas es privado
    Given url baseUrl + '/storage/v1/object/public/team-documents/qa-no-existe.pdf'
    And header apikey = anonKey
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/storage/v1/object/public/team-documents/qa-no-existe.pdf', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[400,404]}, responseStatus, response)
    Then match err == ''

  Scenario: TC-I06 El ping keep_alive responde
    Given url baseUrl + '/rest/v1/keep_alive?select=id&id=eq.1'
    And header apikey = anonKey
    When method get
    * def ev = ({ request: { method: 'GET', url: baseUrl + '/rest/v1/keep_alive?select=id&id=eq.1', body: null }, response: { status: responseStatus, time_ms: responseTime, body: response } })
    * karate.embed(karate.toString(ev), 'application/json')
    * def err = check({"status":[200],"nonEmpty":true}, responseStatus, response)
    Then match err == ''

