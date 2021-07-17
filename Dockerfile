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
COPY sources.list /etc/apt/sources.list
RUN apt update && \
    apt upgrade -y && \
    apt dist-upgrade -y

RUN apt install -y \
        linux-generic \
        live-boot

CMD /bin/bash

FROM ubuntu:focal AS BUILD_SQUASHFS

COPY --from=IMAGE / /rootfs

RUN apt update \
 && apt install -y \
        mtools \
        squashfs-tools \
        xorriso

WORKDIR /workspace
COPY entry_point.sh /
CMD /bin/bash /entry_point.sh
