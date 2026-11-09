KERNEL_IMAGETYPE:qemux86-64 = "freebsd-kernel"
SERIAL_CONSOLES:qemux86-64 = "115200;ttyu0"

# FreeBSD world supplies tar; Linux helpers and modules do not apply.
MACHINE_ESSENTIAL_EXTRA_RDEPENDS:remove:qemux86-64 = "v86d tar"
MACHINE_EXTRA_RRECOMMENDS:remove:qemux86-64 = "kernel-module-snd-ens1370 kernel-module-snd-rawmidi"

QB_TAP_NAMESERVER ?= "8.8.8.8"
