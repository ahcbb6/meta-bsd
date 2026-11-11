# FreeBSD libc already supplies ndbm.h and its matching implementation.
EXTRA_OECONF:remove:class-target:freebsd = "--enable-libgdbm-compat"
EXTRA_OECONF:append:class-target:freebsd = " --disable-libgdbm-compat"

do_install:append:class-target:freebsd() {
    rm ${D}${includedir}/gdbm/ndbm.h
}
