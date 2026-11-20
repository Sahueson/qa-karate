@ignore
Feature: Login reutilizable (devuelve token y id de usuario)

  Scenario:
    Given url baseUrl + '/auth/v1/token?grant_type=password'
    And header apikey = anonKey
    And request { email: '#(email)', password: '#(qaPassword)' }
    When method post
    Then status 200
    * def token = response.access_token
    * def uid = response.user.id
