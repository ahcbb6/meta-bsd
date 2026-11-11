# FreeBSD's ncurses reads the base termcap database; keep its vi command.
RDEPENDS:${PN}:remove:class-target:libc-freebsd = "ncurses-terminfo-base"
ALTERNATIVE:${PN}:class-target:libc-freebsd = "vim"
DEPENDS:append:class-target:libc-freebsd = " virtual/libintl"
# The development image is console-only, without freedesktop MIME integration.
PACKAGECONFIG:remove:class-target:libc-freebsd = "desktop"
# Let Vim's link probe discover FreeBSD's timer functions in librt.
EXTRA_OECONF:remove:class-target:libc-freebsd = "vim_cv_timer_create=yes"

do_install:append:class-target:libc-freebsd() {
    rm ${D}${bindir}/ex ${D}${bindir}/view
}
