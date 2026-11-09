SITEINFO_EXTRA_DATAFUNCS:append = " bsd_siteinfo"

def bsd_siteinfo(archinfo, osinfo, targetinfo, d):
    freebsd_os = d.getVar("FREEBSD_TARGET_OS")
    if freebsd_os:
        targetinfo["x86_64-" + freebsd_os] = "bit-64"
    return archinfo, osinfo, targetinfo
