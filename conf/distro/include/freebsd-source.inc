FREEBSD_VERSION ?= "15.1"
FREEBSD_TARGET_OS = "freebsd${FREEBSD_VERSION}"
require conf/distro/include/freebsd-${FREEBSD_VERSION}.inc

REQUIRED_VERSION_freebsd-base = "${FREEBSD_VERSION}"
REQUIRED_VERSION_freebsd-tools-native = "${FREEBSD_VERSION}"
