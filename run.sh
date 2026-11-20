#!/usr/bin/env bash
# Ejecuta la suite de Karate contra el staging y escribe result.json (formato del lab).
#   SUITE=api  ./run.sh
# Necesita Java 17+ y .karate/karate.jar (se descarga solo si falta: KARATE_VERSION, 1.5.1 por defecto).
# Con STG_SECRET_KEY reserva y resetea el staging; sin ella (local) solo lanza las pruebas.
set -euo pipefail
cd "$(dirname "$0")"
SUITE=$(printf %s "${SUITE:-api}" | tr -cd 'a-z0-9,-')
export SUITE
KV="${KARATE_VERSION:-1.5.1}"
if [ ! -f .karate/karate.jar ]; then
  mkdir -p .karate
  curl -fsSL -o .karate/karate.jar "https://github.com/karatelabs/karate/releases/download/v${KV}/karate-${KV}.jar"
fi
rm -rf target result.json
run() {
  java -jar .karate/karate.jar -f '~html,cucumber:json' -o target features/api.feature || true
  node to-result.js target/karate-reports result.json
}
if [ -n "${STG_SECRET_KEY:-}" ] && [ -f shared/reset-staging/with-staging.js ]; then
  export -f run; exec node shared/reset-staging/with-staging.js -- bash -c run
else
  run
fi
