# Shared paths keep FreeBSD and BusyBox in the same alternatives groups.
FREEBSD_ALTERNATIVE_PATHS = " \
    /bin/[ /bin/cat /bin/chmod /bin/cp /bin/date /bin/echo /bin/expr \
    /bin/ln /bin/ls /bin/mkdir /bin/mv /bin/pwd /bin/realpath /bin/rm \
    /bin/rmdir /bin/sleep /bin/test \
    /sbin/md5sum /sbin/sha1sum /sbin/sha256sum /sbin/sha512sum \
    /usr/bin/basename /usr/bin/chgrp /usr/bin/cmp /usr/bin/cut \
    /usr/bin/dirname /usr/bin/du /usr/bin/egrep /usr/bin/env /usr/bin/false \
    /usr/bin/fgrep /usr/bin/find /usr/bin/grep /usr/bin/groups \
    /usr/bin/gunzip /usr/bin/gzip /usr/bin/head /usr/bin/id \
    /usr/bin/install /usr/bin/less /usr/bin/lesskey \
    /usr/bin/mkfifo /usr/bin/mktemp /usr/bin/od \
    /usr/bin/printf /usr/bin/readlink /usr/bin/sed /usr/bin/seq \
    /usr/bin/sort /usr/bin/split /usr/bin/tail /usr/bin/tar /usr/bin/tee \
    /usr/bin/touch /usr/bin/tr /usr/bin/true /usr/bin/uname /usr/bin/uniq \
    /usr/bin/wc /usr/bin/whoami /usr/bin/xargs /usr/bin/yes /usr/bin/zcat \
    /usr/sbin/chown \
"
