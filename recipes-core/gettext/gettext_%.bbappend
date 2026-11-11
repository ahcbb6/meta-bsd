# External GLib needs the libintl supplied by gettext on FreeBSD, creating a cycle.
PACKAGECONFIG:remove:class-target:libc-freebsd = "glib"
