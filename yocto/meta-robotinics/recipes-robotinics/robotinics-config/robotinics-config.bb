SUMMARY = "Robotinics base configuration"
LICENSE = "MIT"
SRC_URI = "file://robotinics.env file://robotinics.conf"
S = "${UNPACKDIR}"

inherit allarch

do_install() {
    install -d ${D}${sysconfdir}/robotinics
    install -m 0644 ${S}/robotinics.env ${D}${sysconfdir}/robotinics/robotinics.env
    install -m 0644 ${S}/robotinics.conf ${D}${sysconfdir}/robotinics/robotinics.conf
    install -d ${D}/opt/robotinics/docs
    install -d ${D}/var/lib/robotinics
    install -d ${D}/var/log/robotinics
}

FILES:${PN} += "/opt/robotinics /var/lib/robotinics /var/log/robotinics"
