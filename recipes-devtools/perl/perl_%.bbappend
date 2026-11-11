# Errno's build-time interpreter is Linux, but its headers must be from FreeBSD.
PACKAGECONFIG_CONFARGS:append:class-target:freebsd = " -Dsysroot=${STAGING_DIR_HOST} \
    -Dosname=freebsd -Dosvers=${FREEBSD_VERSION} -Darchname=${TARGET_ARCH}-freebsd \
    -Dd_nanosleep=define -Dlibswanted='m crypt pthread'"

# libc's pthread stubs are not a substitute for the real threads library.
CFLAGS:append:class-target:freebsd = " -pthread"
LDFLAGS:append:class-target:freebsd = " -pthread"

# OE hardcodes the Linux architecture directory in configure/install/packaging.
# Keep those paths in sync with perl-cross's actual FreeBSD archname.
python __anonymous() {
    if d.getVar("CLASSOVERRIDE") != "class-target" or d.getVar("TCLIBC") != "freebsd":
        return
    for name in list(d.keys()):
        value = d.getVar(name, False)
        if isinstance(value, str) and "${TARGET_ARCH}-linux" in value:
            d.setVar(name, value.replace("${TARGET_ARCH}-linux", "${TARGET_ARCH}-${TCLIBC}"))
    split = d.getVar("split_perl_packages", False)
    d.setVar("split_perl_packages", split.replace(".*linux", ".*" + d.getVar("TCLIBC")))
    configure = d.getVar("do_configure", False)
    d.setVar("do_configure", configure.replace("-Dd_gnulibc=define", "-Ud_gnulibc"))
}
