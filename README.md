# meta-bsd
BSD distribution layer compatible with OpenEmbedded.

The initial supported distribution is FreeBSD, with its native kernel, userspace
and rc init system. Following upstream FreeBSD's use of Clang/LLVM, the FreeBSD
kernel and userspace are built using the Clang/LLVM toolchain provided by
BitBake.

Currently supported BSPs:
- QEMU x86-64 (OE-Core's `qemux86-64` machine)

## Dependencies

This layer depends on:

     URI: https://git.openembedded.org/bitbake
     branch: master

     URI: https://git.openembedded.org/openembedded-core
     branch: master

The layer declares compatibility with the `blacksail` OpenEmbedded release
series.

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

## Build and run FreeBSD

4. Build the image:

```bash
bitbake freebsd-image
```

The image includes the FreeBSD base system, kernel, bootloader and network
configuration. Bootable Wic disk images and root filesystem archives are
generated under `tmp/deploy/images/qemux86-64/`.

5. Boot the image in QEMU with a serial console and user-mode networking:

```bash
runqemu qemux86-64 freebsd-image nographic slirp
```

Log in as `root` without a password. Networking is configured automatically.

This is a development image with passwordless root access, not a hardened
production image.
