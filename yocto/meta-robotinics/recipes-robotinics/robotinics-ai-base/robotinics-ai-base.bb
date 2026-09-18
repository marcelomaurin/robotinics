SUMMARY = "Robotinics AI runtime base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
SRC_URI = "file://robotinics-ai.env file://README"
S = "${UNPACKDIR}"

inherit allarch

do_install() {
    install -d ${D}${sysconfdir}/robotinics
    install -m 0644 ${S}/robotinics-ai.env ${D}${sysconfdir}/robotinics/robotinics-ai.env
    install -d ${D}/opt/robotinics/ai
    install -m 0644 ${S}/README ${D}/opt/robotinics/ai/README
}

FILES:${PN} += "/opt/robotinics/ai"
