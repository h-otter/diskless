#!/bin/bash
set -x
set -e

mkdir -p /workspace
mv /rootfs/boot /workspace

mksquashfs \
  /rootfs /workspace/rootfs.squashfs \
  -comp gzip \
  -xattrs \
  -noD \
  -progress
