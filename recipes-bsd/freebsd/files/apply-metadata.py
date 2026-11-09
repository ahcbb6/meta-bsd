#!/usr/bin/env python3
# SPDX-License-Identifier: MIT

# Import ownership and permissions from mtree-normalized FreeBSD NO_ROOT
# install metadata under pseudo so OE packages retain the intended attributes.

import os
from pathlib import Path
import re
import stat
import sys


def apply_metadata(root, specification):
    root = Path(root).resolve()
    normalized_links = 0
    types = {
        "dir": stat.S_ISDIR, "file": stat.S_ISREG, "link": stat.S_ISLNK,
        "char": stat.S_ISCHR, "block": stat.S_ISBLK, "fifo": stat.S_ISFIFO,
    }
    with open(specification, encoding="utf-8") as stream:
        for line in stream:
            name, *attributes = line.split()
            if not re.fullmatch(r"(?:[^\\]|\\[0-7]{3}|\\\\)*", name):
                raise ValueError(f"Unsupported mtree path escape: {name}")
            name = os.fsdecode(re.sub(
                rb"\\([0-7]{3}|\\)",
                lambda match: bytes([int(match[1], 8)]) if match[1] != b"\\" else b"\\",
                os.fsencode(name),
            ))
            if Path(name).is_absolute() or ".." in Path(name).parts:
                raise ValueError(f"Metadata path escapes root: {name}")
            path = root / name
            if not path.parent.resolve().is_relative_to(root) and path != root / ".":
                raise ValueError(f"Metadata path escapes root: {name}")
            fields = dict(attribute.split("=", 1) for attribute in attributes)
            if set(fields) != {"type", "uid", "gid", "mode"}:
                raise ValueError(f"Incomplete or unexpected metadata for {name}: {fields}")
            info = path.lstat()
            if not types[fields["type"]](info.st_mode):
                raise ValueError(f"Installed file type differs from METALOG: {name}")
            uid, gid, mode = int(fields["uid"]), int(fields["gid"]), int(fields["mode"], 8)
            os.chown(path, uid, gid, follow_symlinks=False)
            if stat.S_ISLNK(info.st_mode):
                normalized_links += mode != 0o777
                mode = 0o777
            else:
                os.chmod(path, mode)
            info = path.lstat()
            if (info.st_uid, info.st_gid, stat.S_IMODE(info.st_mode)) != (uid, gid, mode):
                raise RuntimeError(f"Installed metadata verification failed: {name}")
    print(f"Verified METALOG metadata; retained Linux mode 0777 on {normalized_links} symlinks")


if __name__ == "__main__":
    apply_metadata(*sys.argv[1:])
