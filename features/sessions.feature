@ignore
Feature: Sesiones de los usuarios QA (se calculan una sola vez por ejecución)

  Scenario:
    * def superadmin = call read('login.feature') { email: 'qa.superadmin@example.com', qaPassword: '#(qaPassword)' }
    * def admin_mad = call read('login.feature') { email: 'qa.admin.mad@example.com', qaPassword: '#(qaPassword)' }
    * def admin_foe = call read('login.feature') { email: 'qa.admin.foe@example.com', qaPassword: '#(qaPassword)' }
    * def junta2 = call read('login.feature') { email: 'qa.junta2@example.com', qaPassword: '#(qaPassword)' }
    * def player_foe = call read('login.feature') { email: 'qa.player.foe@example.com', qaPassword: '#(qaPassword)' }
    * def player_mad = call read('login.feature') { email: 'qa.player.mad@example.com', qaPassword: '#(qaPassword)' }
    * def blocked = call read('login.feature') { email: 'qa.blocked@example.com', qaPassword: '#(qaPassword)' }
    * def sinequipo = call read('login.feature') { email: 'qa.sinequipo@example.com', qaPassword: '#(qaPassword)' }
    * def sessions = { superadmin: '#(superadmin)', admin_mad: '#(admin_mad)', admin_foe: '#(admin_foe)', junta2: '#(junta2)', player_foe: '#(player_foe)', player_mad: '#(player_mad)', blocked: '#(blocked)', sinequipo: '#(sinequipo)' }
