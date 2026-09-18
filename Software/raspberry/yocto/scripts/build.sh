#!/bin/sh
set -eu

"$ROOT/scripts/bootstrap-fpc.sh"
export PATH="$ROOT/.tools/fpc/bin:$PATH"
export ROBOTINICS_FPC_SOURCE="$ROOT/.tools/fpc-src"
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TARGET=${1:-rpi4}

case "$TARGET" in
  rpi4) MANIFEST="$ROOT/kas/robotinics-rpi4.yml" ;;
  rpi5) MANIFEST="$ROOT/kas/robotinics-rpi5.yml" ;;
  *) echo "uso: $0 [rpi4|rpi5]" >&2; exit 2 ;;
esac

command -v kas >/dev/null 2>&1 || { echo "kas nao encontrado" >&2; exit 1; }
exec kas build "$MANIFEST"
