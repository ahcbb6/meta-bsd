# The compiler sysroot supplies libunistring without absolute library paths.
EXTRA_OECONF:remove:class-target:libc-freebsd = "--with-libunistring-prefix=${STAGING_EXECPREFIXDIR}"
EXTRA_OECONF:append:class-target:libc-freebsd = " --without-libunistring-prefix"
