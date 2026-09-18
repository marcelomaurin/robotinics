SUMMARY = "Robotinics TCHATGPT voice command compatibility layer"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://robotinics-speak file://robotinics-read-file file://robotinics-voice"
S = "${UNPACKDIR}"

RDEPENDS:${PN} = "bash alsa-utils-aplay"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/robotinics-speak ${D}${bindir}/robotinics-speak
    install -m 0755 ${S}/robotinics-read-file ${D}${bindir}/robotinics-read-file
    install -m 0755 ${S}/robotinics-voice ${D}${bindir}/robotinics-voice
}
