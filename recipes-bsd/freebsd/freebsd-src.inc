SRC_URI = "git://github.com/freebsd/freebsd-src.git;protocol=https;branch=${FREEBSD_BRANCH};destsuffix=freebsd"
SRC_URI += "file://0003-native-elf-format-respect-configured-compiler.patch \
            file://0004-bmake-skip-racy-interrupt-test-on-linux.patch"
SRCREV = "${FREEBSD_SRCREV}"
BB_GIT_SHALLOW = "1"
BB_GIT_SHALLOW_DEPTH = "1"
S = "${UNPACKDIR}/freebsd"
B = "${WORKDIR}/build"
