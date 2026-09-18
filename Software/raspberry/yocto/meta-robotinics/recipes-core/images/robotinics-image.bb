SUMMARY = "Robotinics Raspberry Pi image"
DESCRIPTION = "Headless Robotinics image with serial gateway, networking, speech/vision options and AI runtime foundation."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit core-image

IMAGE_FEATURES += "ssh-server-openssh"

IMAGE_INSTALL:append = " packagegroup-robotinics robotinics-config robotinics-gateway robotinics-ai-base robotinics-docs"
IMAGE_INSTALL:append = "${@bb.utils.contains('ROBOTINICS_FEATURES', 'speech', ' robotinics-voice-interface', '', d)}"
IMAGE_INSTALL:append = "${@bb.utils.contains('ROBOTINICS_FEATURES', 'vision', ' v4l-utils opencv', '', d)}"

IMAGE_INSTALL:append = "${@bb.utils.contains('ROBOTINICS_FEATURES', 'ai', ' robotinics-ai-api', '', d)}"
