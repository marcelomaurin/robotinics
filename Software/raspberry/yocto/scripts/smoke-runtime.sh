#!/bin/sh
set -eu

GATEWAY=${ROBOTINICS_GATEWAY_URL:-http://127.0.0.1:8765}
AI=${ROBOTINICS_AI_URL:-http://127.0.0.1:8766}

echo "== Gateway =="
curl -fsS "$GATEWAY/v1/ping"
echo
curl -fsS "$GATEWAY/v1/state"
echo

echo "== AI =="
curl -fsS "$AI/v1/ping"
echo

if [ "$#" -gt 0 ]; then
  QUESTION="$*"
  PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"question":" ".join(sys.argv[1:])}))' "$QUESTION")
  curl -fsS -X POST "$AI/v1/ask" \
    -H 'Content-Type: application/json' \
    -d "$PAYLOAD"
  echo
fi
