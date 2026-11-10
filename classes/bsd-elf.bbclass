PACKAGEQA_EXTRA_MACHDEFFUNCS:append = " bsd_elf_machine"

def bsd_elf_machine(machdata, d):
    freebsd_os = d.getVar("FREEBSD_TARGET_OS")
    if freebsd_os:
        machdata[freebsd_os] = {
            "x86_64": (62, 9, 0, True, 64),
            "aarch64": (183, 9, 0, True, 64),
        }
    return machdata
