SUMMARY = "Robotinics Lazarus/FPC TCHATGPT voice runtime"
DESCRIPTION = "Cross-compiles the headless Robotinics voice application for Raspberry Pi ARM64 using Free Pascal and the Yocto cross binutils."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = " \
    file://robotinics_voice.lpr \
    file://aibase.pas \
    file://aivoicesynthesizer.pas \
    file://TCHATGPT_SOURCE \
"

S = "${UNPACKDIR}"

DEPENDS = "binutils-cross-${TARGET_ARCH}"

RDEPENDS:${PN} = "alsa-utils-aplay ca-certificates openssl"

COMPATIBLE_HOST = "aarch64.*-linux"

do_compile() {
    if [ -z "${ROBOTINICS_FPC_SOURCE}" ]; then
        bbfatal "ROBOTINICS_FPC_SOURCE nao definido. Use scripts/build.sh ou scripts/bootstrap-fpc.sh."
    fi

    if [ ! -d "${ROBOTINICS_FPC_SOURCE}/compiler" ]; then
        bbfatal "Fonte FPC invalida em ${ROBOTINICS_FPC_SOURCE}"
    fi

    FPC_HOST="$(command -v fpc || true)"
    if [ -z "$FPC_HOST" ]; then
        bbfatal "Bootstrap FPC nao encontrado no PATH. Execute scripts/bootstrap-fpc.sh."
    fi

    rm -rf "${B}/fpc-src" "${B}/fpc-cross" "${B}/units"
    mkdir -p "${B}/fpc-src" "${B}/fpc-cross" "${B}/units"

    cp -a "${ROBOTINICS_FPC_SOURCE}/." "${B}/fpc-src/"

    bbnote "Construindo cross compiler Free Pascal para aarch64-linux"
    make -C "${B}/fpc-src" clean

    make -C "${B}/fpc-src" all \
        FPC="$FPC_HOST" \
        OS_TARGET=linux \
        CPU_TARGET=aarch64 \
        CROSSINSTALL=1 \
        CROSSBINDIR="${STAGING_BINDIR_TOOLCHAIN}" \
        BINUTILSPREFIX="${TARGET_PREFIX}" \
        OPT="-O2"

    make -C "${B}/fpc-src" crossinstall \
        FPC="$FPC_HOST" \
        OS_TARGET=linux \
        CPU_TARGET=aarch64 \
        CROSSINSTALL=1 \
        CROSSBINDIR="${STAGING_BINDIR_TOOLCHAIN}" \
        BINUTILSPREFIX="${TARGET_PREFIX}" \
        INSTALL_PREFIX="${B}/fpc-cross" \
        OPT="-O2"

    PPCROSS="$(find "${B}/fpc-cross" "${B}/fpc-src/compiler" -type f -name ppcrossa64 | head -n 1)"
    if [ -z "$PPCROSS" ] || [ ! -x "$PPCROSS" ]; then
        bbfatal "ppcrossa64 nao foi produzido pelo build FPC"
    fi

    UNITROOT="$(find "${B}/fpc-cross" -type d -path '*/units/aarch64-linux' | head -n 1)"
    if [ -z "$UNITROOT" ]; then
        bbfatal "Units aarch64-linux do FPC nao encontradas"
    fi

    FU_ARGS=""
    for unitdir in $(find "$UNITROOT" -type d); do
        FU_ARGS="$FU_ARGS -Fu$unitdir"
    done

    bbnote "Compilando robotinics-voice para ARM64"
    "$PPCROSS" \
        -Tlinux -Paarch64 -n -O2 -Xs \
        -XR"${RECIPE_SYSROOT}" \
        -FD"${STAGING_BINDIR_TOOLCHAIN}" \
        -XP"${TARGET_PREFIX}" \
        $FU_ARGS \
        -Fu"${S}" \
        -FU"${B}/units" \
        -FE"${B}" \
        -o"${B}/robotinics-voice" \
        "${S}/robotinics_voice.lpr"

    test -x "${B}/robotinics-voice" || bbfatal "robotinics-voice nao foi gerado"
}

do_install() {
    install -d ${D}/opt/robotinics/voice
    install -m 0755 ${B}/robotinics-voice ${D}/opt/robotinics/voice/robotinics-voice
    install -m 0644 ${S}/TCHATGPT_SOURCE ${D}/opt/robotinics/voice/TCHATGPT_SOURCE
}

FILES:${PN} += "/opt/robotinics/voice"
