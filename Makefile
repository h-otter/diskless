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
	docker run -it --rm -v $(CURDIR)/var:/dst h-otter/ceph-diskless /bin/bash /entry_point.sh

image:
	rm -rf var
	docker build -t h-otter/diskless .
	docker run -it --rm -v $(CURDIR)/var:/workspace h-otter/diskless

vm:
	qemu-system-x86_64 -enable-kvm -cpu host -m 4G -serial stdio \
		-initrd var/boot/initrd.img \
		-kernel var/boot/vmlinuz \
		-append 'console=tty1 console=ttyS0,115200 boot=live noeject swap=false ramdisk-size=1G fetch=http://192.168.122.1:8080/rootfs.squashfs'
