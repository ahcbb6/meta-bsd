SUMMARY = "FreeBSD development image with a local passwordless root login"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

require conf/distro/include/freebsd-source.inc
inherit bsd-image image_types_freebsd

COMPATIBLE_MACHINE = "^(qemux86-64|qemuarm64)$"
IMAGE_INSTALL = "freebsd-base freebsd-base-files freebsd-kernel freebsd-bootloader bsd-network"

IMAGE_FSTYPES = "tar.zst wic"
WKS_FILE:qemux86-64 = "freebsd-x86-64.wks.in"
WKS_FILE:qemuarm64 = "freebsd-aarch64.wks.in"
WKS_FILE_DEPENDS:append:qemuarm64 = " dosfstools-native mtools-native"
IMAGE_BOOT_FILES:qemuarm64 = "${STAGING_LIBDIR}/freebsd-boot/loader.efi;EFI/BOOT/BOOTAA64.EFI"
DEPENDS:append:qemuarm64 = " qemu-system-native"

QB_DEFAULT_FSTYPE = "wic"
QB_DEFAULT_KERNEL = "none"
QB_KERNEL_CMDLINE_APPEND = ""
QB_KERNEL_CMDLINE_APPEND:remove = "swiotlb=0"
QB_DEFAULT_BIOS:qemuarm64 = "${DEPLOY_DIR_IMAGE}/edk2-aarch64-code.fd"
# runqemu uses this prefix to select IDE; FreeBSD calls the disk ada0.
QB_DRIVE_TYPE:qemux86-64 = "/dev/hd"
# For Wic images runqemu selects the disk interface here, not via QB_ROOTFS_OPT.
QB_DRIVE_TYPE:qemuarm64 = "/dev/vd"
QB_RNG = ""
QB_OPT_APPEND:append = " -no-reboot"

freebsd_deploy_qemu_firmware() {
    install -m 0644 ${STAGING_DATADIR_NATIVE}/qemu/edk2-aarch64-code.fd ${IMGDEPLOYDIR}/
}
IMAGE_PREPROCESS_COMMAND:append:qemuarm64 = " freebsd_deploy_qemu_firmware"

python () {
    if d.getVar("MACHINE") != "qemux86-64":
        return
    # The OE machine adds Syslinux Wic dependencies independently of WKS_FILE.
    linux_boot_dependencies = {
        "syslinux:do_populate_sysroot",
        "syslinux-native:do_populate_sysroot",
        "mtools-native:do_populate_sysroot",
        "dosfstools-native:do_populate_sysroot",
    }
    dependencies = (d.getVarFlag("do_image_wic", "depends") or "").split()
    d.setVarFlag("do_image_wic", "depends", " ".join(
        dependency for dependency in dependencies
        if dependency not in linux_boot_dependencies
    ))
}
