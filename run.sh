#!/usr/bin/env bash
# Ejecuta suites de Karate (un .feature por suite) contra el staging y escribe result.json (formato del lab).
#   SUITE=a-auth[,b-eventos...]  GREP='TC-A01 Anónimo…|TC-A02 …' (opcional)  ./run.sh
# Usa el CLI `karate` (2.x) si está instalado; si no, el JAR standalone .karate/karate.jar
# (se descarga solo: KARATE_VERSION, 1.5.1 por defecto). Necesita Java 17+ y Node 22.
# GREP filtra los resultados por nombre de caso (to-result.js); SUITE elige los .feature a ejecutar.
# Con STG_SECRET_KEY reserva y resetea el staging; sin ella (local) solo lanza las pruebas.
set -euo pipefail
cd "$(dirname "$0")"
ALL="a-auth,b-eventos,c-inscripciones,d-asistencia,e-gobernanza,f-excedencias,g-jugadores,h-calendario,i-normas"
SUITE=$(printf %s "${SUITE:-$ALL}" | tr -cd 'a-z0-9,-')
export SUITE
rm -rf target result.json
run() {
  # la lista se calcula aquí dentro: los arrays de Bash no sobreviven a `export -f` + `bash -c run`
  local features=()
  IFS=',' read -ra list <<< "$SUITE"
  for s in "${list[@]}"; do [ -f "features/$s.feature" ] && features+=("features/$s.feature"); done
  if command -v karate >/dev/null 2>&1; then
    karate run -f '~html,cucumber:json' -o target "${features[@]}" || true
  else
    KV="${KARATE_VERSION:-1.5.1}"
    if [ ! -f .karate/karate.jar ]; then
      mkdir -p .karate
      curl -fsSL -o .karate/karate.jar "https://github.com/karatelabs/karate/releases/download/v${KV}/karate-${KV}.jar"
    fi
    # classpath con la carpeta actual (classpath:features/... y helpers) + el JAR standalone
    java -cp ".karate/karate.jar:." com.intuit.karate.Main -f '~html,cucumber:json' -o target "${features[@]}" || true
  fi
  node to-result.js target result.json
}
if [ -n "${STG_SECRET_KEY:-}" ] && [ -f shared/reset-staging/with-staging.js ]; then
  export -f run; exec node shared/reset-staging/with-staging.js -- bash -c run
else
  run
fi
