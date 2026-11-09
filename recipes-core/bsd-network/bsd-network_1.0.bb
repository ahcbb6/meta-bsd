SUMMARY = "Native BSD guest networking for OE runqemu"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
SRC_URI = "file://bsd-network file://bsd-network-rc"
S = "${UNPACKDIR}"
PACKAGE_ARCH = "${MACHINE_ARCH}"
INHIBIT_DEFAULT_DEPS = "1"

do_install() {
    install -Dm0755 ${S}/bsd-network ${D}${sbindir}/bsd-network
    sed -i 's/@TAP_NAMESERVER@/${QB_TAP_NAMESERVER}/g' ${D}${sbindir}/bsd-network
}

do_install:append:libc-freebsd() {
    install -Dm0755 ${S}/bsd-network-rc ${D}${sysconfdir}/rc.d/bsd_network
}

RDEPENDS:${PN}:libc-freebsd = "freebsd-base"
