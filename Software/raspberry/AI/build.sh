#!/bin/sh
set -eu
command -v lazbuild >/dev/null 2>&1 || {
  echo "lazbuild nao encontrado" >&2
  exit 1
}
exec lazbuild robotinics_ai.lpi
