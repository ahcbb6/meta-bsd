inherit image_types_bsd

DEPENDS += "freebsd-tools-native freebsd-base"
BSD_MAKEFS = "${STAGING_DIR_NATIVE}${libexecdir_native}/freebsd/makefs"
BSD_MBR_BOOT = "${STAGING_LIBDIR}/freebsd-boot/pmbr"
BSD_FFS_OPTIONS = "version=2,bsize=16384,fsize=2048"
