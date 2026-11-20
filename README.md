# qa-karate

Pruebas de API con Karate (DSL Gherkin, un solo JAR, sin Maven) contra el staging de Tactical Calendar.
Los mismos 17 casos `TC-API01..17` que Newman y Bruno: RLS anónimo (11) y visibilidad por rol (6,
tag `@auth`, se omiten sin `QA_PASSWORD`).

    QA_PASSWORD=... ./run.sh     # descarga .karate/karate.jar si falta y escribe result.json

Requisitos: Java 17+ y Node 22 (solo para convertir el informe al formato del lab).
