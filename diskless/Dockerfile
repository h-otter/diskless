FROM h-otter/ubuntu-rootfs:bionic

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
 && apt install -y \
       curl
RUN apt update \
 && apt install -y \
        live-boot \
        live-boot-initramfs-tools \
        mtools \
        squashfs-tools \
        xorriso \
 && mkdir -p /isoroot/live

COPY entry_point.sh /entry_point.sh
COPY cloudinit.cfg /etc/cloud/cloud.cfg.d/live-cd.cfg
COPY grub.cfg /boot/grub/grub.cfg

ARG USER_NAME=diskless
ARG USER_PASSWORD=D!skless
RUN useradd -m -s /bin/bash -G sudo ${USER_NAME} \
 && printf "${USER_PASSWORD}\n${USER_PASSWORD}" | passwd ${USER_NAME}
