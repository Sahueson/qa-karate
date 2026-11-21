Feature: i-normas · API del staging (RLS y roles)

  Background:
    * url baseUrl
    * def check = read('helpers/check.js')

  Scenario: TC-I01 Anónimo no lee documentos del equipo
    Given url baseUrl + '/rest/v1/team_documents?select=id'
    And header apikey = anonKey
    When method get
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
    * def err = check({"status":[200],"isArray":true}, responseStatus, response)
    Then match err == ''

  @auth
  Scenario: TC-I03 Jugador MAD no sube documentos
    * if (!qaPassword) karate.abort()
    * def session = karate.callSingle('classpath:features/sessions.feature').sessions.player_mad
    Given url baseUrl + '/rest/v1/team_documents'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + session.token
    And request {"squad":"MAD Irregulars","category":"bof","title":"QA","file_url":"x","file_path":"x"}
    When method post
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
    * def err = check({"blocked":true}, responseStatus, response)
    Then match err == ''

  Scenario: TC-I05 El bucket de normas es privado
    Given url baseUrl + '/storage/v1/object/public/team-documents/qa-no-existe.pdf'
    And header apikey = anonKey
    When method get
    * def err = check({"status":[400,404]}, responseStatus, response)
    Then match err == ''

  Scenario: TC-I06 El ping keep_alive responde
    Given url baseUrl + '/rest/v1/keep_alive?select=id&id=eq.1'
    And header apikey = anonKey
    When method get
    * def err = check({"status":[200],"nonEmpty":true}, responseStatus, response)
    Then match err == ''

