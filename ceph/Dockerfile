FROM h-otter/ubuntu-diskless:bionic

# for Japan region
RUN sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list

# installing GRUB will be failed
RUN wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add - \
 && apt-add-repository 'deb https://download.ceph.com/debian-luminous/ bionic main' \
 && apt update \
 && apt install -y \
        ceph \
 && apt install -y linux-generic-hwe-18.04 || true
