all: update-rootfs build-ubuntu-diskless build-ceph-diskless build-ceph

update-rootfs:
	mkdir -p var
	wget -O var/bionic-server-cloudimg-amd64-root.tar.xz https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64-root.tar.xz
	docker import var/bionic-server-cloudimg-amd64-root.tar.xz h-otter/ubuntu-rootfs:bionic

build-ubuntu-diskless:
	docker build -t h-otter/ubuntu-diskless:bionic diskless

build-ceph-diskless: build-ubuntu-diskless
	docker build -t h-otter/ceph-diskless ceph

build-ceph: build-ceph-diskless
	docker run -it --rm -v $(PWD)/var:/dst ceph-docker /bin/bash /entry_point.sh
