image:
	rm -rf var
	docker build -t h-otter/diskless .
	docker run -it --rm -v $(CURDIR)/var:/workspace h-otter/diskless

vm:
	qemu-system-x86_64 -enable-kvm -cpu host -m 4G -serial stdio \
		test.img \
		-initrd var/boot/initrd.img \
		-kernel var/boot/vmlinuz \
		-append 'console=tty1 console=ttyS0,115200 boot=live noeject swap=false ramdisk-size=512M fetch=http://192.168.122.1:8080/rootfs.squashfs'
