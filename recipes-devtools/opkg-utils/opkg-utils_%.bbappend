PACKAGECONFIG:class-target:freebsd = "update-alternatives"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append:class-target:freebsd = " file://0001-update-alternatives-use-portable-sed-expressions.patch"
