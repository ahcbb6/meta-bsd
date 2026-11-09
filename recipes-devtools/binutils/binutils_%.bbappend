# OE's native recipe needs libbfd/libopcodes/libiberty, not libctf. The latter
# retains a build-tree libiberty search path in its installed .la files.
EXTRA_OECONF:append:class-native:freebsd = " --disable-libctf"
