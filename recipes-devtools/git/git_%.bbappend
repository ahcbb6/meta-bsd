FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append:class-target:freebsd = " file://0001-config.mak.uname-avoid-host-BSD-prefixes-when-cross.patch"

# Git's makefiles inspect the build host independently of configure.
EXTRA_OEMAKE:append:class-target:freebsd = " uname_S=FreeBSD uname_R=${FREEBSD_VERSION} uname_M=${TARGET_ARCH} CROSS_COMPILE=${TARGET_PREFIX}"
