#!/bin/sh -eux

file=$1
efi_part_label=i_t14sg6_efi
nix_part_label=i_t14sg6_nix
boot_size=256M

fallocate -l4G ${file}

parted ${file} mklabel gpt
parted ${file} mkpart ${efi_part_label} fat32 0% ${boot_size}
parted ${file} set 1 esp on
parted ${file} mkpart ${nix_part_label} ext3 ${boot_size} 100%

drive=$(losetup -P -f --show ${file})

mkfs.vfat -F32 ${drive}p1
mkfs.ext3 ${drive}p2

mkdir -p /mnt
mount ${drive}p2 /mnt
mkdir /mnt/boot
mount ${drive}p1 /mnt/boot

mkdir -p /mnt/etc/nixos
cp -r pkgs *.nix /mnt/etc/nixos/
nixos-install --root /mnt --no-root-password

umount -R /mnt
losetup -D
