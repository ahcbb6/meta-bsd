FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
require recipes-bsd/freebsd/freebsd-alternatives.inc

# These fragments would override the selected FreeBSD defconfig.
SRC_URI:remove:class-target:freebsd += "file://login-utilities.cfg"
SRC_URI:remove:class-target:freebsd += "file://mount-via-label.cfg"
SRC_URI:remove:class-target:freebsd += "file://mkdosfs.cfg"
SRC_URI:remove:class-target:freebsd += "file://getopts.cfg"
SRC_URI:remove:class-target:freebsd += "file://longopts.cfg"
SRC_URI:remove:class-target:freebsd += "file://resize.cfg"
SRC_URI:remove:class-target:freebsd += "file://init.cfg"
SRC_URI:remove:class-target:freebsd += "file://mdev.cfg"
SRC_URI:remove:class-target:freebsd += "file://syslog.cfg"
SRC_URI:remove:class-target:freebsd += "file://unicode.cfg"
SRC_URI:remove:class-target:freebsd += "file://rev.cfg"
SRC_URI:remove:class-target:freebsd += "file://pgrep.cfg"
SRC_URI:remove:class-target:freebsd += "file://fdisk-gpt.cfg"
SRC_URI:remove:class-target:freebsd += "file://sha_accel.cfg"
BUSYBOX_SPLIT_SUID:class-target:freebsd = "0"
EXTRA_OEMAKE:append:class-target:freebsd = " AR='${AR}'"
RRECOMMENDS:${PN}:remove:class-target:freebsd = "${PN}-udhcpc"

# OE removes all CONFIG_STATIC* entries, including our compiler-runtime choice.
do_prepare_config:append:class-target:freebsd() {
    echo "# CONFIG_STATIC_LIBGCC is not set" >> ${S}/.config
}

python freebsd_busybox_links() {
    from pathlib import Path

    paths = {os.path.basename(path): path
             for path in d.getVar("FREEBSD_ALTERNATIVE_PATHS").split()}
    directory = Path(d.expand("${D}${sysconfdir}"))
    for links in directory.glob("busybox.links*"):
        entries = links.read_text().splitlines()
        links.write_text("".join(paths.get(os.path.basename(path), path) + "\n"
                                 for path in entries))
}
python __anonymous() {
    if d.getVar("CLASSOVERRIDE") == "class-target" and "freebsd" in d.getVar("DISTROOVERRIDES").split(":"):
        d.appendVarFlag("do_install", "postfuncs", " freebsd_busybox_links")
}
