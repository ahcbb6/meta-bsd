FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append:class-target:freebsd = " file://0001-configure-support-FreeBSD-cross-builds.patch \
    file://0002-build-details-record-target-extension-suffix.patch"

# Keep line editing without colliding with the base system's libedit headers.
PACKAGECONFIG:remove:class-target:freebsd = "editline"
PACKAGECONFIG:append:class-target:freebsd = " readline"

# The FreeBSD compiler runtime supplies the required atomics.
CACHED_CONFIGUREVARS:remove:class-target:freebsd = "ac_cv_libatomic_needed=yes"
CACHED_CONFIGUREVARS:append:class-target:freebsd = " ac_cv_libatomic_needed=no"

# CPython supports the native FreeBSD UUID API; do not shadow its uuid.h.
DEPENDS:remove:class-target:freebsd = "util-linux-libuuid"
CPPFLAGS:remove:class-target:freebsd = "-I${STAGING_INCDIR}/uuid"

# Dots in the versioned target OS break sysconfig's Python module name.
EXTRA_OECONF:remove:class-target:freebsd = "PLATFORM_TRIPLET=${HOST_ARCH}-${HOST_OS}"
EXTRA_OECONF:append:class-target:freebsd = " PLATFORM_TRIPLET=${HOST_ARCH}-freebsd"
