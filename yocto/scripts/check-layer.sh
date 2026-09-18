#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MANIFEST="$ROOT/kas/robotinics-rpi4.yml"
command -v kas >/dev/null 2>&1 || { echo "kas nao encontrado" >&2; exit 1; }
kas shell "$MANIFEST" -c "bitbake-layers show-layers && bitbake -e robotinics-image >/dev/null"
