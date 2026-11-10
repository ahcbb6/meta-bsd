IMAGE_TYPES += "ffs"
WKS_FILE_DEPENDS = "wic-native parted-native"
IMAGE_TYPEDEP:wic = "ffs"
IMAGE_ROOTFS_ALIGNMENT = "16"
BSD_FFS_OPTIONS ?= "version=1,bsize=16384,fsize=2048"
EXTRA_IMAGECMD:ffs ?= "-o density=4096"

IMAGE_CMD:ffs() {
    ${BSD_MAKEFS} -t ffs -B little -T ${SOURCE_DATE_EPOCH} \
        -s ${ROOTFS_SIZE}k -o ${BSD_FFS_OPTIONS} ${EXTRA_IMAGECMD} \
        ${IMGDEPLOYDIR}/${IMAGE_NAME}.ffs ${IMAGE_ROOTFS}
}

python bsd_disk_mbr() {
    from pathlib import Path

    boot = Path(d.getVar("BSD_MBR_BOOT")).read_bytes()
    if len(boot) != 512 or boot[510:] != b"\x55\xaa":
        bb.fatal("Invalid BSD MBR boot code")
    with Path(d.expand("${IMGDEPLOYDIR}/${IMAGE_NAME}.wic")).open("r+b") as stream:
        mbr = stream.read(512)
        if mbr[510:] != b"\x55\xaa":
            bb.fatal("Wic did not create an MBR")
        # Preserve Wic's disk signature and partition table.
        stream.seek(0)
        stream.write(boot[:440])
}
do_image_wic[postfuncs] += "${@'bsd_disk_mbr' if d.getVar('TARGET_ARCH') == 'x86_64' else ''}"
