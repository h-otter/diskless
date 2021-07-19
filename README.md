# diskless

## build image

```sh
make image
```

## Run the generated image with QEMU

1. Host `rootfs.squashfs`

```sh
python -m http.server 8000
```

2. Execute QEMU with PXE boot
    - change the host on fetch option to download `rootfs.squashfs` from nginx which is started on step 1

```sh
make vm
```
