# Linux user-mode QEMU cannot execute BSD binaries.
EXEWRAPPER_ENABLED:class-target = "False"

BSD_CMAKE_SYSTEM_NAME:freebsd = "FreeBSD"
BSD_CMAKE_SYSTEM_VERSION:freebsd = "${FREEBSD_VERSION}"

# Clang does not implement GCC's --print-sysroot used by Libtool's autodetection.
oe_runconf:prepend:class-target() {
    if grep -q -- '--with-sysroot' ${CONFIGURE_SCRIPT}; then
        set -- --with-sysroot=${STAGING_DIR_HOST} "$@"
    fi
}

# The generic dispatcher includes glibc's bits/wordsize.h.
oe_multilib_header:prepend:class-target() {
    if [ -n "${MULTILIB_VARIANTS}" ]; then
        bbfatal "${BSD_CMAKE_SYSTEM_NAME} multilib header dispatch is not implemented"
    fi
    return
}

cmake_do_generate_toolchain_file:append:class-target() {
    cat >> ${WORKDIR}/toolchain.cmake <<EOF
set(CMAKE_SYSTEM_NAME ${BSD_CMAKE_SYSTEM_NAME})
set(CMAKE_SYSTEM_VERSION ${BSD_CMAKE_SYSTEM_VERSION})
EOF
}

python bsd_meson_system() {
    if d.getVar("CLASSOVERRIDE") == "class-target" and bb.data.inherits_class("meson", d):
        from pathlib import Path
        config = Path(d.expand("${WORKDIR}/meson.cross"))
        text = config.read_text()
        config.write_text(text.replace("system = '" + d.getVar("TARGET_OS") + "'",
                                       "system = '" + d.getVar("TCLIBC") + "'"))
}
do_write_config[postfuncs] += "bsd_meson_system"
