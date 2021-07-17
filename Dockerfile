FROM ubuntu:focal AS DEBOOTSTRAP

RUN apt update && \
    apt install -y debootstrap

RUN mkdir -p /rootfs && \
    debootstrap \
        --arch=amd64 \
        focal \
        /rootfs \
        http://ftp.jaist.ac.jp/pub/Linux/ubuntu/


FROM scratch AS IMAGE
COPY --from=DEBOOTSTRAP /rootfs /

ENV DEBIAN_FRONTEND=noninteractive
COPY rootfs/etc/apt/sources.list /etc/apt/sources.list
RUN apt update && \
    apt upgrade -y && \
    apt dist-upgrade -y

RUN apt install -y \
        linux-generic \
        live-boot \
        openssh-server \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

# containerd
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable" && \
    apt update && \
    apt install -y containerd.io && \
    mkdir -p /etc/containerd && \
    containerd config default | sudo tee /etc/containerd/config.toml

# kubernetes
RUN apt-get install -y iptables arptables ebtables && \
    update-alternatives --set iptables /usr/sbin/iptables-legacy && \
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy && \
    update-alternatives --set arptables /usr/sbin/arptables-legacy && \
    update-alternatives --set ebtables /usr/sbin/ebtables-legacy && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
COPY rootfs/etc/apt/sources.list.d/kubernetes.list /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update && \
    apt-get install -y kubelet kubeadm kubectl && \
    apt-mark hold kubelet kubeadm kubectl


# packages
RUN apt install -y \
        nano \
        tcpdump \
        frr

COPY rootfs/etc/fstab /etc/fstab
RUN mkdir -p /mnt/nvme

# files
COPY rootfs/etc/modules-load.d/* /etc/modules-load.d
COPY rootfs/etc/sysctl.d/* /etc/sysctl.d

# user
ARG USER_NAME=diskless
ARG USER_PASSWORD=diskless
RUN useradd -m -s /bin/bash -G sudo ${USER_NAME} && \
    echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd

# locale and time
RUN echo "Asia/Tokyo" >  /etc/timezone && \
    ln -s -f /usr/share/zoneinfo/Japan /etc/localtime && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
COPY rootfs/etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf


# clean up
RUN apt autoremove --purge -y && \
    apt autoclean -y && \
    apt clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

CMD /bin/bash


FROM ubuntu:focal AS BUILD_SQUASHFS

RUN apt update \
 && apt install -y \
        mtools \
        squashfs-tools \
        xorriso

COPY --from=IMAGE / /rootfs
RUN echo diskless > /rootfs/etc/hostname

WORKDIR /workspace
COPY entry_point.sh /
CMD /bin/bash /entry_point.sh
