SUMMARY = "Pinned TCHATGPT source snapshot for Robotinics development"
DESCRIPTION = "Installs a reproducible TCHATGPT source snapshot for ARM64 integration work. It does not claim a validated native Raspberry Pi build."
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1ebbd3e34237af26da5dc08a4e440464"

SRC_URI = "git://github.com/marcelomaurin/CHATGPT.git;protocol=https;branch=main"
SRCREV = "e593fb758801cecb087e55e3222fc513cc35fee2"
S = "${WORKDIR}/git"

inherit allarch

EXCLUDE_FROM_WORLD = "1"

do_install() {
    install -d ${D}/opt/robotinics/tchatgpt-src
    cp -R --no-dereference --preserve=mode,timestamps ${S}/pacote ${D}/opt/robotinics/tchatgpt-src/
    install -m 0644 ${S}/README.md ${D}/opt/robotinics/tchatgpt-src/README.md
    install -m 0644 ${S}/LICENSE ${D}/opt/robotinics/tchatgpt-src/LICENSE
}

FILES:${PN} += "/opt/robotinics/tchatgpt-src"
