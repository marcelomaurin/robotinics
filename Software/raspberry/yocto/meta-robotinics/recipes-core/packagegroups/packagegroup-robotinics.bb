SUMMARY = "Robotinics runtime package group"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit packagegroup

RDEPENDS:${PN} = " bash ca-certificates curl git openssh python3 python3-core python3-json python3-logging python3-pyserial python3-requests util-linux i2c-tools usbutils networkmanager networkmanager-nmcli wpa-supplicant"
