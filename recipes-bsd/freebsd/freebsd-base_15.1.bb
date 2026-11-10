SUMMARY = "FreeBSD base system and kernel built with the OE LLVM toolchain"
LICENSE = "BSD-2-Clause AND BSD-3-Clause AND BSD-4-Clause AND ISC AND MIT"
LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=05a8a3274bdffd66f88f061859a648c1"

require conf/distro/include/freebsd-${PV}.inc
require freebsd-src.inc
inherit freebsd-make deploy

COMPATIBLE_HOST = "(x86_64|aarch64)-.*-freebsd.*"
INHIBIT_DEFAULT_DEPS = "1"
DEPENDS += "virtual/cross-cc virtual/cross-binutils"
PROVIDES = "virtual/libc virtual/libiconv virtual/kernel virtual/compilerlibs compiler-rt libcxx \
            openssl zlib ncurses bzip2 xz virtual/crypt"
PSEUDO_PASSWD = "${WORKDIR}/pseudo-passwd:${STAGING_DIR_TARGET}:${PSEUDO_SYSROOT}"
SRC_URI += "file://src.conf file://apply-metadata.py \
            file://0001-ncurses-declare-build-tool-header-prerequisites.patch \
            file://0002-newvers-support-GNU-date-for-reproducible-builds.patch"

do_configure[noexec] = "1"
FREEBSD_BOOT_FILES = "pmbr gptboot"
FREEBSD_BOOT_FILES:aarch64 = "loader.efi"
do_compile() {
    install -d ${B}/obj
    freebsd_make buildworld
    freebsd_make WERROR= buildkernel
}

do_install() {
    export LOCALBASE=/usr/local
    freebsd_make DESTDIR=${D} NO_ROOT=yes STRIP= installworld distribution
    freebsd_make DESTDIR=${D} NO_ROOT=yes STRIP= reinstallkernel
    ${FREEBSD_BOOTSTRAP_TOOLS}/usr/sbin/mtree -C -M -N ${D}/etc \
        -k type,uid,gid,mode -f ${D}/METALOG > ${WORKDIR}/install.mtree
    ${PYTHON} ${UNPACKDIR}/apply-metadata.py ${D} ${WORKDIR}/install.mtree
    # Native header generators record their source filenames in comments.
    grep -rlZ -F "${S}/" ${D}${includedir} > ${WORKDIR}/generated-headers.list || \
        test $? -eq 1
    xargs -0 -r sed -i 's|${S}/|/usr/src/|g' < ${WORKDIR}/generated-headers.list
    rm ${D}/METALOG
    rm -f ${D}/etc/rc.conf ${D}/etc/fstab ${D}/etc/ttys \
        ${D}/boot/loader.conf ${D}/boot.config ${D}/root/.shrc
    install -d ${D}${libdir}/freebsd-boot
    for file in ${FREEBSD_BOOT_FILES}; do
        install -m 0644 ${D}/boot/$file ${D}${libdir}/freebsd-boot/
    done
    freebsd_install_accounts ${WORKDIR}/pseudo-passwd
}

PACKAGES =+ "freebsd-kernel freebsd-bootloader freebsd-rtld freebsd-rtld-dbg ${PN}-modules ${PN}-bootblocks"
FILES:freebsd-kernel = "/boot/kernel"
FILES:freebsd-bootloader = "/boot"
FILES:freebsd-rtld = "/libexec/ld-elf.so.1"
FILES:freebsd-rtld-dbg = "/libexec/.debug/ld-elf.so.1"
FILES:${PN}-modules = "${libdir}/pam_*.so* ${libdir}/snmp_*.so* \
                      ${libdir}/nss_*.so* ${libdir}/i18n \
                      ${libdir}/krb5/plugins/*/*.so* \
                      ${base_libdir}/libalias_*.so ${libdir}/libomp.so"
FILES:${PN}-bootblocks = "${libdir}/freebsd-boot"
FILES:${PN} = "/"
RDEPENDS:${PN} += "freebsd-rtld ${PN}-modules"
RPROVIDES:${PN} += "openssl openssl-bin bzip2 xz"
# These are runtime module entry points, not development linker symlinks.
INSANE_SKIP:${PN}-modules = "dev-so"
# The native kernel relocation model and ELF interpreter path are ABI choices.
INSANE_SKIP:freebsd-kernel = "textrel"
INSANE_SKIP:freebsd-rtld = "libdir"
INSANE_SKIP:freebsd-rtld-dbg = "libdir"
QA_EMPTY_DIRS:remove = "${localstatedir}/run"
SYSROOT_DIRS += "${libdir}/freebsd-boot"
SYSROOT_PREPROCESS_FUNCS += "freebsd_stage_accounts"

freebsd_install_accounts() {
    install -d "$1${sysconfdir}"
    install -m 0644 ${D}${sysconfdir}/passwd ${D}${sysconfdir}/group \
        "$1${sysconfdir}/"
    # OE permission fixups name group 0 "root"; FreeBSD names it "wheel".
    printf 'root:*:0:\n' >> "$1${sysconfdir}/group"
}

freebsd_stage_accounts() {
    freebsd_install_accounts ${SYSROOT_DESTDIR}
}

do_deploy() {
    install -Dm0644 ${D}/boot/kernel/kernel ${DEPLOYDIR}/freebsd-kernel
}
addtask deploy after do_install before do_build
