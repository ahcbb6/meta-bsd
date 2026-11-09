SUMMARY = "Native FreeBSD filesystem and account database tools"
LICENSE = "BSD-2-Clause AND BSD-3-Clause AND BSD-4-Clause AND ISC AND MIT"
LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=05a8a3274bdffd66f88f061859a648c1"

require conf/distro/include/freebsd-${PV}.inc
require freebsd-src.inc
SRC_URI += "file://src.conf"
inherit freebsd-make native

do_configure[noexec] = "1"
do_compile() {
    freebsd_make _worldtmp
    freebsd_make _legacy
    freebsd_make _bootstrap-tools
}

do_install() {
    install -d ${D}${libexecdir}/freebsd
    install -m 0755 ${FREEBSD_BOOTSTRAP_TOOLS}/usr/sbin/makefs \
        ${FREEBSD_BOOTSTRAP_TOOLS}/usr/sbin/pwd_mkdb \
        ${D}${libexecdir}/freebsd/
}
