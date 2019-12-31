#!/bin/bash
set -x
set -e


# cat <<EOF | tee /etc/cloud/cloud.cfg.d/n0stack.cfg
# # /etc/hostname, /etc/resolv.conf and /etc/hosts is managed by Docker on container.
# # Although /etc/hostname and /etc/resolv.conf is managed by systemd and cloud-init on booted machine,
# # /etc/hosts is not modified by default.
# # Therefore this configuration is necessaly.
# manage_etc_hosts: True

# datasource_list: [NoCloud]
# datasource:
#   NoCloud:
#     meta-data:
# `cat /etc/cloud/meta-data | sed 's/^/      /'`

#     user-data: |
# `cat /etc/cloud/user-data | sed 's/^/      /'`

# EOF

sed -i -e "s|__VMLINUZ__|`ls /boot/initrd.img* | head -1`|g" /boot/grub/grub.cfg
sed -i -e "s|__INITRD__|`ls /boot/vmlinuz* | head -1`|g" /boot/grub/grub.cfg
cp -r /boot /isoroot/boot


# wget -O/isoroot/live/rootfs.squashfs http://cdimage.ubuntu.com/ubuntu-server/daily/current/eoan-server-amd64.squashfs
mksquashfs \
  / /isoroot/live/rootfs.squashfs \
  -comp gzip \
  -xattrs \
  -noD \
  -progress \
  -regex \
  -e \
  '^proc$/.*' \
  '^dev$/.*' \
  '^sys$/.*' \
  '^tmp$/.*' \
  '^etc$/hostname' \
  '^etc$/hosts' \
  '^boot$/.*' \
  '^isoroot$/.*' \
  '^dst$/.*'
  # -mem 5G \

cp /isoroot/live/rootfs.squashfs /dst/rootfs.squashfs
cp `ls /boot/initrd.img* | tail -1` /dst/initrd.img
cp `ls /boot/vmlinuz* | tail -1` /dst/vmlinuz
grub-mkrescue -o /dst/live.iso /isoroot
