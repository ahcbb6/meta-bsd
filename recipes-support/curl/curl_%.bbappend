fix_absolute_paths:append:class-target:libc-freebsd() {
    sed -i -e "s|'--with-sysroot=${STAGING_DIR_HOST}' ||g" ${D}${bindir}/curl-config
}
