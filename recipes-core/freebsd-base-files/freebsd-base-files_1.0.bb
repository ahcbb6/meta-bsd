SUMMARY = "FreeBSD local serial development console configuration"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
SRC_URI = "file://rc.conf file://fstab file://ttys file://loader.conf file://local.lua file://boot.config file://shrc"
S = "${UNPACKDIR}"
PACKAGE_ARCH = "${MACHINE_ARCH}"
INHIBIT_DEFAULT_DEPS = "1"

do_install() {
    install -d ${D}/etc ${D}/boot/lua ${D}/root
    install -m 0644 ${S}/rc.conf ${S}/fstab ${S}/ttys ${D}/etc/
    install -m 0644 ${S}/loader.conf ${D}/boot/loader.conf
    install -m 0644 ${S}/local.lua ${D}/boot/lua/local.lua
    install -m 0644 ${S}/boot.config ${D}/boot.config
    install -m 0644 ${S}/shrc ${D}/root/.shrc
    chmod 0750 ${D}/root
}

FILES:${PN} = "/etc /boot/loader.conf /boot/lua/local.lua /boot.config /root"
RDEPENDS:${PN} = "freebsd-base"
RPROVIDES:${PN}:libc-freebsd = "base-files"

python freebsd_install_osrelease_hook() {
    from pathlib import Path
    import re
    import shlex

    variant = d.getVar("BSD_OS_VARIANT")
    variant_id = d.getVar("BSD_OS_VARIANT_ID")
    if not variant or any(char in variant for char in "\r\n\0"):
        bb.fatal("BSD_OS_VARIANT must be a nonempty single-line string")
    if not variant_id or not re.fullmatch(r"[a-z0-9._-]+", variant_id):
        bb.fatal("BSD_OS_VARIANT_ID must contain only lowercase letters, digits, '.', '_' or '-'")
    # Quote once for os-release syntax, then for the shell command emitting it.
    for char in '\\\"$`':
        variant = variant.replace(char, "\\" + char)
    fields = ['VARIANT="' + variant + '"', "VARIANT_ID=" + variant_id]
    directory = Path(d.expand("${D}${sysconfdir}/rc.conf.d"))
    directory.mkdir(parents=True, exist_ok=True)
    config = directory / "osrelease"
    config.write_text(
        "osrelease_add_build_info()\n{\n"
        "    printf '%s\\n' " + " ".join(shlex.quote(field) for field in fields) +
        ' >> "${osrelease_file}"\n'
        '}\n\nstart_postcmd="osrelease_add_build_info"\n',
        encoding="utf-8",
    )
    config.chmod(0o644)
}
do_install[postfuncs] += "freebsd_install_osrelease_hook"
