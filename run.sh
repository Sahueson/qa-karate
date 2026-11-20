#!/usr/bin/env bash
# Ejecuta la suite de Karate contra el staging y escribe result.json (formato del lab).
#   SUITE=api  ./run.sh
# Usa el CLI `karate` (2.x) si está instalado; si no, el JAR standalone .karate/karate.jar
# (se descarga solo: KARATE_VERSION, 1.5.1 por defecto). Necesita Java 17+ y Node 22.
# Con STG_SECRET_KEY reserva y resetea el staging; sin ella (local) solo lanza las pruebas.
set -euo pipefail
cd "$(dirname "$0")"
SUITE=$(printf %s "${SUITE:-api}" | tr -cd 'a-z0-9,-')
export SUITE
rm -rf target result.json
run() {
  if command -v karate >/dev/null 2>&1; then
    karate run -f '~html,cucumber:json' -o target features/api.feature || true
  else
    KV="${KARATE_VERSION:-1.5.1}"
    if [ ! -f .karate/karate.jar ]; then
      mkdir -p .karate
      curl -fsSL -o .karate/karate.jar "https://github.com/karatelabs/karate/releases/download/v${KV}/karate-${KV}.jar"
    fi
    java -jar .karate/karate.jar -f '~html,cucumber:json' -o target features/api.feature || true
  fi
  node to-result.js target result.json
}
if [ -n "${STG_SECRET_KEY:-}" ] && [ -f shared/reset-staging/with-staging.js ]; then
  export -f run; exec node shared/reset-staging/with-staging.js -- bash -c run
else
  run
fi
