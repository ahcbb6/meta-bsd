# meta-bsd
BSD distribution layer compatible with the Yocto Project/OpenEmbedded.

The initial supported distribution is FreeBSD, with its native kernel, userspace
and rc init system. Following upstream FreeBSD's use of Clang/LLVM, the FreeBSD
kernel and userspace are built using the Clang/LLVM toolchain provided by
BitBake.

Currently supported BSPs:
- qemux86-64
- qemuarm64

## Dependencies

This layer depends on:

     URI: https://git.openembedded.org/bitbake
     branch: master

     URI: https://git.openembedded.org/openembedded-core
     branch: master

## License

This layer has an MIT license (see [LICENSE](LICENSE)). FreeBSD and the other
components fetched during the build retain their own licenses, as declared in
their recipes.

## FreeBSD build setup

1. Clone the required repositories into the same directory:

```bash
git clone https://git.openembedded.org/bitbake
git clone https://git.openembedded.org/openembedded-core
git clone https://github.com/ahcbb6/meta-bsd.git
```

2. Initialize the build environment and add meta-bsd to your layer configuration:

```bash
source openembedded-core/oe-init-build-env builds/freebsd
bitbake-layers add-layer ../../meta-bsd
```

The environment setup changes the current directory to `builds/freebsd`.
Run the remaining commands from that directory.

3. Set the distribution and machine in `conf/local.conf`, replacing any existing
   assignments for these variables:

```bitbake
DISTRO = "freebsd"
MACHINE = "qemux86-64"
```

For ARM64, use `MACHINE = "qemuarm64"` instead.

## Build and run FreeBSD

4. Build the image:

```bash
bitbake freebsd-image
```

The image includes the FreeBSD base system, kernel, bootloader and network
configuration. Bootable Wic disk images and root filesystem archives are
generated under `tmp/deploy/images/<machine>/`.

The ARM64 image boots through UEFI using FreeBSD's `loader.efi`. The build
deploys QEMU's packaged `edk2-aarch64-code.fd` firmware alongside the image for
`runqemu`.

5. Boot the image in QEMU with a serial console and user-mode networking:

```bash
runqemu nographic slirp
```

Log in as `root` without a password. Networking is configured automatically.

This is a development image with passwordless root access, not a hardened
production image.

