# FreeBSD getcwd(NULL, 0) allocates its result; the cross probe defaults to no.
CACHED_CONFIGUREVARS:append:class-target:libc-freebsd = " bash_cv_getcwd_malloc=yes bash_cv_sys_named_pipes=present"

# devfs provides only standard descriptors; use FIFOs without requiring fdescfs.
CACHED_CONFIGUREVARS:append:class-target:freebsd = " bash_cv_dev_fd=absent"

# FreeBSD init requires its native /bin/sh and the -o verify option.
ALTERNATIVE:${PN}:remove:class-target:freebsd = "sh"
