# qa-karate

Pruebas de API con Karate (DSL Gherkin) contra el staging de Tactical Calendar.
Los mismos 57 casos `TC-API01..58` que Newman y Bruno, un `.feature` por suite (a-auth … i-normas) en `features/`.
Los casos con login llevan el tag `@auth` y se omiten sin `QA_PASSWORD`; las sesiones de los usuarios QA se calculan una vez
por ejecución (`features/sessions.feature`).

    SUITE=a-auth,b-eventos QA_PASSWORD=... ./run.sh     # sin SUITE ejecuta las 9; escribe result.json

Requisitos: Java 17+, Node 22 y el CLI `karate` (2.x) o, si no está, el JAR 1.x que `run.sh` descarga.
