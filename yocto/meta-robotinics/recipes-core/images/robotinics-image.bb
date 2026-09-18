SUMMARY = "Robotinics Raspberry Pi image"
DESCRIPTION = "Headless Robotinics image with serial gateway, networking, speech/vision options and AI runtime foundation."
LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += "ssh-server-openssh"

IMAGE_INSTALL:append = " packagegroup-robotinics robotinics-config robotinics-gateway robotinics-ai-base"
IMAGE_INSTALL:append = "${@bb.utils.contains('ROBOTINICS_FEATURES', 'speech', ' robotinics-speech espeak', '', d)}"
IMAGE_INSTALL:append = "${@bb.utils.contains('ROBOTINICS_FEATURES', 'vision', ' v4l-utils opencv', '', d)}"
