inherit core-image

# These development images do not implement Linux live images or SDKs.
IMGCLASSES:remove = "image-live populate_sdk_ext"
deltask do_populate_sdk

IMAGE_FEATURES += "empty-root-password allow-empty-password allow-root-login"
IMAGE_ROOTFS_SIZE ?= "8192"
ROOTFS_BOOTSTRAP_INSTALL = ""
