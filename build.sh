#!/bin/bash

set -xe

TARGET=hello.img
MOUNT=mnt

gcc hello.c -c -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -I /usr/include/efi/ -I /usr/include/efi/x86_64/ -DEFI_FUNCTION_WRAPPER -o hello.o
ld hello.o /usr/lib/crt0-efi-x86_64.o -nostdlib -znocombreloc -T /usr/lib/elf_x86_64_efi.lds -shared -Bsymbolic -L /usr/lib -l:libgnuefi.a -l:libefi.a -o hello.so
objcopy -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .reloc --target=efi-app-x86_64 hello.so hello.efi

# Create an image with enough space for the EFI executable.
# TODO: Can we create an image with exactly the right size easily?
truncate -s100M $TARGET

fdisk $TARGET << EOF
g
n


+50M
t
1
n



w
EOF

losetup /dev/loop0 $TARGET

# Format the image.
mkfs.vfat -F32 /dev/loop0p1

# Create a mountpoint to mount the image through a loopback interface.
mkdir -p $MOUNT 
mount /dev/loop0p1 $MOUNT

bootctl install --path $MOUNT
ls -la $MOUNT

exit 0

# Clean up the mount, our image should be ready.
umount $MOUNT
losetup -d /dev/loop0
rm -r $MOUNT

