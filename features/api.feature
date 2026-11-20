Feature: Tactical Calendar API (staging) · RLS y roles

  Background:
    * url baseUrl
    * def emails = { superadmin: 'qa.superadmin@example.com', player_mad: 'qa.player.mad@example.com', player_foe: 'qa.player.foe@example.com', blocked: 'qa.blocked@example.com' }

  Scenario: TC-API01 Anónimo no ve partidas (RLS)
    Given path 'rest/v1/events'
    And param select = 'id'
    And header apikey = anonKey
    When method get
    Then status 200
    And match response == []

  Scenario: TC-API02 Anónimo no ve inscripciones (RLS)
    Given path 'rest/v1/event_registrations'
    And param select = 'id'
    And header apikey = anonKey
    When method get
    Then status 200
    And match response == []

  Scenario: TC-API03 Anónimo no ve votaciones FOE (RLS)
    Given path 'rest/v1/foe_polls'
    And param select = 'id'
    And header apikey = anonKey
    When method get
    Then status 200
    And match response == []

  Scenario: TC-API04 Anónimo no ve faltas FOE (RLS)
    Given path 'rest/v1/foe_infractions'
    And param select = 'id'
    And header apikey = anonKey
    When method get
    Then status 200
    And match response == []

  Scenario: TC-API05 Anónimo no lee perfiles
    Given path 'rest/v1/profiles'
    And param select = 'id'
    And header apikey = anonKey
    When method get
    Then assert responseStatus == 401 || responseStatus == 403

  Scenario: TC-API06 Anónimo no crea partidas
    Given path 'rest/v1/events'
    And header apikey = anonKey
    And request { title: 'x' }
    When method post
    Then assert responseStatus == 401 || responseStatus == 403

  Scenario: TC-API07 Anónimo no crea excedencias
    Given path 'rest/v1/player_leaves'
    And header apikey = anonKey
    And request { reason: 'x' }
    When method post
    Then assert responseStatus == 401 || responseStatus == 403

  Scenario: TC-API08 Anónimo no borra partidas
    Given path 'rest/v1/events'
    And param id = 'not.is.null'
    And header apikey = anonKey
    When method delete
    Then assert responseStatus == 401 || responseStatus == 403

  Scenario: TC-API09 El ping keep_alive responde
    Given path 'rest/v1/keep_alive'
    And params { select: 'id', id: 'eq.1' }
    And header apikey = anonKey
    When method get
    Then status 200
    And match response == '#[1]'

  Scenario: TC-API10 Sin apikey se rechaza
    Given path 'rest/v1/events'
    And param select = 'id'
    When method get
    Then status 401

  Scenario: TC-API11 Login con contraseña incorrecta falla
    Given path 'auth/v1/token'
    And param grant_type = 'password'
    And header apikey = anonKey
    And request { email: 'qa.player.mad@example.com', password: 'contraseña-incorrecta' }
    When method post
    Then status 400
    And match response.error_code == 'invalid_credentials'

  @auth
  Scenario: TC-API12 Login correcto devuelve token
    * if (!qaPassword) karate.abort()
    Given path 'auth/v1/token'
    And param grant_type = 'password'
    And header apikey = anonKey
    And request { email: '#(emails.player_mad)', password: '#(qaPassword)' }
    When method post
    Then status 200
    And match response.access_token == '#string'

  @auth
  Scenario: TC-API13 Jugador MAD solo ve partidas de su equipo
    * if (!qaPassword) karate.abort()
    * def token = call read('login.feature') { email: '#(emails.player_mad)', qaPassword: '#(qaPassword)' }
    Given path 'rest/v1/events'
    And param select = 'id,squad'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + token.token
    When method get
    Then status 200
    And match response == '#[_ > 0]'
    And match each response contains { squad: 'MAD Irregulars' }

  @auth
  Scenario: TC-API14 Jugador FOE no ve partidas de MAD
    * if (!qaPassword) karate.abort()
    * def token = call read('login.feature') { email: '#(emails.player_foe)', qaPassword: '#(qaPassword)' }
    Given path 'rest/v1/events'
    And param select = 'id,squad'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + token.token
    When method get
    Then status 200
    And match response == '#[_ > 0]'
    And match each response contains { squad: 'FOE' }

  @auth
  Scenario: TC-API15 Bloqueado no ve ninguna partida
    * if (!qaPassword) karate.abort()
    * def token = call read('login.feature') { email: '#(emails.blocked)', qaPassword: '#(qaPassword)' }
    Given path 'rest/v1/events'
    And param select = 'id'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + token.token
    When method get
    Then status 200
    And match response == []

  @auth
  Scenario: TC-API16 Jugador MAD no crea partidas en FOE
    * if (!qaPassword) karate.abort()
    * def token = call read('login.feature') { email: '#(emails.player_mad)', qaPassword: '#(qaPassword)' }
    Given path 'rest/v1/events'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + token.token
    And request { title: 'QA intrusa', squad: 'FOE', date: '2030-01-01', hour: '10:00', event_type: 'normal' }
    When method post
    Then assert responseStatus == 401 || responseStatus == 403

  @auth
  Scenario: TC-API17 Super admin ve partidas de ambos equipos
    * if (!qaPassword) karate.abort()
    * def token = call read('login.feature') { email: '#(emails.superadmin)', qaPassword: '#(qaPassword)' }
    Given path 'rest/v1/events'
    And param select = 'id,squad'
    And header apikey = anonKey
    And header Authorization = 'Bearer ' + token.token
    When method get
    Then status 200
    * def squads = karate.distinct(karate.map(response, function(e){ return e.squad }))
    And match squads contains ['MAD Irregulars', 'FOE']
