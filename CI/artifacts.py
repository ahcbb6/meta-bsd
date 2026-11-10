#!/usr/bin/env python3
# SPDX-License-Identifier: MIT

import argparse
import os
from pathlib import Path
import subprocess


def archive(root, destination, entries):
    subprocess.run(
        ["tar", "-I", "zstd -T2 -3", "-cf", str(destination),
         "-C", str(root), "--null", "-T", "-"],
        input=b"".join(str(path.relative_to(root)).encode() + b"\0" for path in entries),
        check=True,
    )


def images(build, output, machine):
    deploy = build / "tmp/deploy/images" / machine
    entries = sorted(
        path for path in deploy.iterdir()
        if path.name.endswith((".wic", ".tar.zst", ".qemuboot.conf", ".manifest", ".wks", ".fd"))
        or path.name == "freebsd-kernel"
    )
    for suffix in (".wic", ".qemuboot.conf"):
        if not any(path.name.endswith(suffix) and path.is_file() for path in entries):
            raise RuntimeError(f"Missing {suffix} artifact in {deploy}")
    if machine == "qemuarm64" and not (deploy / "edk2-aarch64-code.fd").is_file():
        raise RuntimeError("Missing ARM64 UEFI firmware")
    output.mkdir(parents=True, exist_ok=True)
    archive(deploy, output / f"freebsd-image-{machine}.tar.zst", entries)


def logs(build, output):
    output.mkdir(parents=True, exist_ok=True)
    if not build.exists():
        print("Build directory does not exist; no BitBake diagnostics to collect.")
        return
    entries = sorted({
        path for pattern in (
            "conf/*.conf", "bitbake-cookerdaemon.log",
            "tmp/log/**/*", "tmp/work/**/temp/log.*", "tmp/work/**/temp/run.*",
        )
        for path in build.glob(pattern) if path.is_file()
    })
    if entries:
        archive(build, output / "diagnostics.tar.zst", entries)
    else:
        print("No BitBake diagnostics found.")


def materialize_sstate(root, mirror):
    root = root.resolve(strict=True)
    mirror = mirror.resolve(strict=True)
    if root == mirror or root in mirror.parents or mirror in root.parents:
        raise ValueError("Sstate output and mirror must be separate directories")
    count = 0
    for path in root.rglob("*"):
        if not path.is_symlink():
            continue
        target = path.resolve(strict=True)
        if not target.is_file() or mirror not in target.parents:
            raise ValueError(f"Unexpected sstate mirror link: {path} -> {target}")
        temporary = path.with_name(path.name + ".materialized")
        # Both directories live on the same filesystem in the hosted workspace.
        os.link(target, temporary)
        try:
            os.replace(temporary, path)
        finally:
            temporary.unlink(missing_ok=True)
        count += 1
    print(f"Made {count} fetched sstate files independent of the mirror")


def main():
    parser = argparse.ArgumentParser(description="Collect CI images and diagnostics.")
    subparsers = parser.add_subparsers(dest="command", required=True)
    for command in ("images", "logs"):
        subparser = subparsers.add_parser(command)
        subparser.add_argument("build", type=Path)
        subparser.add_argument("output", type=Path)
        subparser.add_argument("machine", choices=("qemux86-64", "qemuarm64"))
    sstate_parser = subparsers.add_parser("sstate")
    sstate_parser.add_argument("root", type=Path)
    sstate_parser.add_argument("mirror", type=Path)
    args = parser.parse_args()
    if args.command == "images":
        images(args.build.resolve(), args.output.resolve(), args.machine)
    elif args.command == "logs":
        logs(args.build.resolve(), args.output.resolve())
    else:
        materialize_sstate(args.root, args.mirror)


if __name__ == "__main__":
    main()
