python freebsd_brand_motd() {
    from pathlib import Path

    message = d.getVar("BSD_MOTD_MESSAGE")
    if not message or any(char in message for char in "\r\n\0"):
        bb.fatal("BSD_MOTD_MESSAGE must be a nonempty single-line string")
    template = Path(d.expand("${D}${sysconfdir}/motd.template"))
    if not template.is_file():
        bb.fatal("Missing upstream MOTD template: " + str(template))
    with template.open("a", encoding="utf-8") as stream:
        stream.write("\n" + message + "\n")
}
do_install[postfuncs] += "freebsd_brand_motd"
