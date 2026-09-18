SUMMARY = "Robotinics runtime package group"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " bash ca-certificates curl git openssh python3 python3-core python3-json python3-logging python3-pyserial python3-requests util-linux i2c-tools usbutils"
