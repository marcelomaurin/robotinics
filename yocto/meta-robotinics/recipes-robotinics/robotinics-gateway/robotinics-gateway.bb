SUMMARY = "Robotinics serial gateway"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
SRC_URI = "file://robotinics-gateway.py file://robotinics-gateway.service"
S = "${UNPACKDIR}"

inherit systemd

RDEPENDS:${PN} = "python3-core python3-json python3-logging python3-pyserial"
SYSTEMD_SERVICE:${PN} = "robotinics-gateway.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/robotinics-gateway.py ${D}${bindir}/robotinics-gateway
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/robotinics-gateway.service ${D}${systemd_system_unitdir}/robotinics-gateway.service
}
