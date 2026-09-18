SUMMARY = "Robotinics TCHATGPT AI runtime"
DESCRIPTION = "Cross-compiles the headless Robotinics AI console runtime for Raspberry Pi ARM64."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = " \
    file://robotinics_ai.lpr \
    file://gatewayclient.pas \
    file://internetservice.pas \
    file://doclookup.pas \
    file://taskengine.pas \
    file://chatgpt.pas \
    file://aibase.pas \
    file://aillmproviders.pas \
    file://aillmmodelcatalog.pas \
    file://aitracebridge.pas \
    file://TCHATGPT_SOURCE \
"

S = "${UNPACKDIR}"

DEPENDS = "binutils-cross-${TARGET_ARCH}"
RDEPENDS:${PN} = "ca-certificates openssl"
COMPATIBLE_HOST = "aarch64.*-linux"

do_compile() {
    if [ -z "${ROBOTINICS_FPC_SOURCE}" ]; then
        bbfatal "ROBOTINICS_FPC_SOURCE nao definido. Execute scripts/build.sh."
    fi

    FPC_HOST="$(command -v fpc || true)"
    if [ -z "$FPC_HOST" ]; then
        bbfatal "Bootstrap FPC nao encontrado no PATH."
    fi

    rm -rf "${B}/fpc-src" "${B}/fpc-cross" "${B}/units"
    mkdir -p "${B}/fpc-src" "${B}/fpc-cross" "${B}/units"
    cp -a "${ROBOTINICS_FPC_SOURCE}/." "${B}/fpc-src/"

    make -C "${B}/fpc-src" clean
    make -C "${B}/fpc-src" all \
        FPC="$FPC_HOST" OS_TARGET=linux CPU_TARGET=aarch64 \
        CROSSINSTALL=1 CROSSBINDIR="${STAGING_BINDIR_TOOLCHAIN}" \
        BINUTILSPREFIX="${TARGET_PREFIX}" OPT="-O2"

    make -C "${B}/fpc-src" crossinstall \
        FPC="$FPC_HOST" OS_TARGET=linux CPU_TARGET=aarch64 \
        CROSSINSTALL=1 CROSSBINDIR="${STAGING_BINDIR_TOOLCHAIN}" \
        BINUTILSPREFIX="${TARGET_PREFIX}" INSTALL_PREFIX="${B}/fpc-cross" \
        OPT="-O2"

    PPCROSS="$(find "${B}/fpc-cross" "${B}/fpc-src/compiler" -type f -name ppcrossa64 | head -n 1)"
    [ -x "$PPCROSS" ] || bbfatal "ppcrossa64 nao encontrado"

    UNITROOT="$(find "${B}/fpc-cross" -type d -path '*/units/aarch64-linux' | head -n 1)"
    [ -n "$UNITROOT" ] || bbfatal "Units aarch64-linux nao encontradas"

    FU_ARGS=""
    for unitdir in $(find "$UNITROOT" -type d); do
        FU_ARGS="$FU_ARGS -Fu$unitdir"
    done

    "$PPCROSS" -Tlinux -Paarch64 -n -O2 -Xs \
        -XR"${RECIPE_SYSROOT}" \
        -FD"${STAGING_BINDIR_TOOLCHAIN}" \
        -XP"${TARGET_PREFIX}" \
        $FU_ARGS -Fu"${S}" -FU"${B}/units" -FE"${B}" \
        -o"${B}/robotinics-ai" "${S}/robotinics_ai.lpr"

    test -x "${B}/robotinics-ai" || bbfatal "robotinics-ai nao gerado"
}

do_install() {
    install -d ${D}/opt/robotinics/ai
    install -m 0755 ${B}/robotinics-ai ${D}/opt/robotinics/ai/robotinics-ai
    install -m 0644 ${S}/TCHATGPT_SOURCE ${D}/opt/robotinics/ai/TCHATGPT_SOURCE
}

FILES:${PN} += "/opt/robotinics/ai"
