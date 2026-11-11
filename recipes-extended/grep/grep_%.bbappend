# Match the native and BusyBox alternatives in /usr/bin, not parallel /bin links.
do_install:append:class-target:freebsd() {
    install -d ${D}${bindir}
    for command in grep egrep fgrep; do
        mv ${D}${base_bindir}/$command ${D}${bindir}/$command
    done
    rmdir ${D}${base_bindir}
}

python __anonymous() {
    if d.getVar("CLASSOVERRIDE") == "class-target" and d.getVar("TCLIBC") == "freebsd":
        for command in ("grep", "egrep", "fgrep"):
            d.setVarFlag("ALTERNATIVE_LINK_NAME", command, d.expand("${bindir}/" + command))
}
