SUMMARY = "Robotinics documentation for local AI context"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "git://github.com/marcelomaurin/robotinics.git;protocol=https;branch=master"
SRCREV = "bf2bc64d610cceb064e48055d35e1c9f017aae6f"
S = "${WORKDIR}/git"

inherit allarch

do_install() {
    install -d ${D}/opt/robotinics/docs

    cp -a ${S}/README.md ${D}/opt/robotinics/docs/
    if [ -f ${S}/README_EN.md ]; then cp -a ${S}/README_EN.md ${D}/opt/robotinics/docs/; fi
    if [ -f ${S}/README_ES.md ]; then cp -a ${S}/README_ES.md ${D}/opt/robotinics/docs/; fi

    cp -a ${S}/docs ${D}/opt/robotinics/docs/project-docs
    cp -a ${S}/Software/arduino ${D}/opt/robotinics/docs/arduino
    cp -a ${S}/Eletronic ${D}/opt/robotinics/docs/Eletronic
    cp -a ${S}/Mecanic ${D}/opt/robotinics/docs/Mecanic

    find ${D}/opt/robotinics/docs -type f \
        ! -name '*.md' ! -name '*.txt' -delete
}

FILES:${PN} += "/opt/robotinics/docs"
