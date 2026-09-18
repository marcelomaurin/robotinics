#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TOOLS="$ROOT/.tools"
CACHE="$TOOLS/cache"
FPC_HOME="$TOOLS/fpc"
FPC_SRC="$TOOLS/fpc-src"
FPC_VERSION=3.2.2
FPC_ARCHIVE="fpc-${FPC_VERSION}.x86_64-linux.tar"
FPC_URL="https://downloads.freepascal.org/fpc/dist/${FPC_VERSION}/x86_64-linux/${FPC_ARCHIVE}"

mkdir -p "$TOOLS" "$CACHE"

if [ ! -x "$FPC_HOME/bin/fpc" ]; then
    echo "[robotinics] instalando bootstrap Free Pascal $FPC_VERSION em $FPC_HOME"

    if [ ! -f "$CACHE/$FPC_ARCHIVE" ]; then
        curl -fL "$FPC_URL" -o "$CACHE/$FPC_ARCHIVE"
    fi

    TMP="$TOOLS/fpc-install"
    rm -rf "$TMP"
    mkdir -p "$TMP"
    tar -xf "$CACHE/$FPC_ARCHIVE" -C "$TMP"

    PKGDIR="$TMP/fpc-${FPC_VERSION}.x86_64-linux"
    [ -x "$PKGDIR/install.sh" ] || {
        echo "install.sh do FPC nao encontrado" >&2
        exit 1
    }

    mkdir -p "$FPC_HOME"

    # O instalador oficial pergunta prefixo e componentes opcionais.
    # Nao instala fontes/docs extras; as fontes usadas no cross build vem do Git.
    printf '%s\nN\nN\nN\n' "$FPC_HOME" | (cd "$PKGDIR" && sh ./install.sh)
fi

if [ ! -d "$FPC_SRC/.git" ]; then
    echo "[robotinics] clonando fonte oficial FPC release_3_2_2"
    git clone --depth 1 --branch release_3_2_2 \
        https://gitlab.com/freepascal.org/fpc/source.git "$FPC_SRC"
fi

"$FPC_HOME/bin/fpc" -iV

echo "[robotinics] FPC_HOME=$FPC_HOME"
echo "[robotinics] FPC_SRC=$FPC_SRC"
