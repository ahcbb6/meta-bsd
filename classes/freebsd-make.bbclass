inherit python3native

FREEBSD_MACHINE ?= "amd64"
FREEBSD_MACHINE_ARCH ?= "amd64"
FREEBSD_OBJTOP = "${B}/obj${S}/${FREEBSD_MACHINE}.${FREEBSD_MACHINE_ARCH}"
FREEBSD_BOOTSTRAP_TOOLS = "${FREEBSD_OBJTOP}/tmp/legacy"
DEBUG_PREFIX_MAP:append = " -ffile-prefix-map=${FREEBSD_OBJTOP}=${TARGET_DBGSRC_DIR} "
DEPENDS += "clang-native lld-native llvm-native bison-native flex-native bc-native \
            coreutils-native time-native xz-native libarchive-native"
do_compile[cleandirs] = "${B}"

freebsd_make() {
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS AS AR LD NM OBJCOPY OBJDUMP RANLIB STRIP
    unset MAKEFLAGS MFLAGS MAKELEVEL MAKEOBJDIR
    # Native dependency paths must follow FreeBSD's bootstrap library paths;
    # otherwise OE's libelf can shadow the incompatible bootstrap libelf.
    install -d ${B}
    cat > ${B}/host-cc <<EOF
#!/bin/sh
exec ${BUILD_CC} ${BUILD_CPPFLAGS} "\$@" ${BUILD_LDFLAGS}
EOF
    cat > ${B}/host-cxx <<EOF
#!/bin/sh
exec ${BUILD_CXX} ${BUILD_CPPFLAGS} "\$@" ${BUILD_LDFLAGS}
EOF
    chmod 0755 ${B}/host-cc ${B}/host-cxx
    export CC="${B}/host-cc" CXX="${B}/host-cxx"
    export CPP="$(command -v ${BUILD_PREFIX}cpp) ${BUILD_CPPFLAGS}"
    export LEX="flex"
    export MAKEOBJDIRPREFIX="${B}/obj"
    export XCC="${STAGING_BINDIR_NATIVE}/clang ${DEBUG_PREFIX_MAP}"
    export XCXX="${STAGING_BINDIR_NATIVE}/clang++ ${DEBUG_PREFIX_MAP}"
    export XCPP="${STAGING_BINDIR_NATIVE}/clang-cpp ${DEBUG_PREFIX_MAP}"
    export XLD="${STAGING_BINDIR_NATIVE}/ld.lld"
    export XAR="${STAGING_BINDIR_NATIVE}/llvm-ar"
    export XNM="${STAGING_BINDIR_NATIVE}/llvm-nm"
    export XOBJCOPY="objcopy"
    export XOBJDUMP="${STAGING_BINDIR_NATIVE}/llvm-objdump"
    export XRANLIB="${STAGING_BINDIR_NATIVE}/llvm-ranlib"
    export XSIZE="${STAGING_BINDIR_NATIVE}/llvm-size"
    export XSTRIPBIN="${STAGING_BINDIR_NATIVE}/llvm-strip"
    install -d ${B}/obj
    ${PYTHON} ${S}/tools/build/make.py --no-clean -C ${S} ${PARALLEL_MAKE} \
        TARGET=${FREEBSD_MACHINE} TARGET_ARCH=${FREEBSD_MACHINE_ARCH} __MAKE_CONF=/dev/null \
        SRCCONF=${UNPACKDIR}/src.conf SRC_ENV_CONF=/dev/null \
        KERNCONF=GENERIC MODULES_OVERRIDE= MK_WERROR=no "$@"
}
