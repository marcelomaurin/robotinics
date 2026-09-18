SUMMARY = "Robotinics AI localhost API"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://robotinics-ai-api.py file://robotinics-ai-api.service"
S = "${UNPACKDIR}"

inherit systemd

RDEPENDS:${PN} = "python3-core robotinics-ai-bin robotinics-gateway"

SYSTEMD_SERVICE:${PN} = "robotinics-ai-api.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/robotinics-ai-api.py ${D}${bindir}/robotinics-ai-api
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/robotinics-ai-api.service ${D}${systemd_system_unitdir}/robotinics-ai-api.service
}
