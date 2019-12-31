# diskless

## build files

```sh
make all
```

## Run the generated image with QEMU

1. Host `rootfs.squashfs` using nginx

```sh
docker run -p 8080:80 -it --rm -v $PWD/var:/usr/share/nginx/html nginx
```

2. Execute QEMU with PXE boot
    - change the host on fetch option to download `rootfs.squashfs` from nginx which is started on step 1

```sh
sudo -E qemu-system-x86_64 -enable-kvm -cpu host -m 4G -serial stdio \
  -initrd var/initrd.img \
  -kernel var/vmlinuz \
  -append 'console=tty1 console=ttyS0,115200 boot=live noeject ramdisk-size=2G fetch=http://192.168.122.1:8080/rootfs.squashfs'
```
