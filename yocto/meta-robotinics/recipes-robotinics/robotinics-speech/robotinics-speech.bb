SUMMARY = "Robotinics speech helper scripts"
LICENSE = "MIT"
SRC_URI = "file://robotinics-speak file://robotinics-read-file"
S = "${UNPACKDIR}"

RDEPENDS:${PN} = "bash espeak"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/robotinics-speak ${D}${bindir}/robotinics-speak
    install -m 0755 ${S}/robotinics-read-file ${D}${bindir}/robotinics-read-file
}
