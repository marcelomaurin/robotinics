#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TARGET=${1:-rpi4}
case "$TARGET" in
  rpi4) MANIFEST="$ROOT/kas/robotinics-rpi4.yml" ;;
  rpi5) MANIFEST="$ROOT/kas/robotinics-rpi5.yml" ;;
  *) echo "uso: $0 [rpi4|rpi5]" >&2; exit 2 ;;
esac
exec kas shell "$MANIFEST"
