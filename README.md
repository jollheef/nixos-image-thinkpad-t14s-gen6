# NixOS image for ThinkPad T14s Gen 6

## Usage

Build

    git clone https://code.dumpstack.io/etc/nixos-image-thinkpad-t14s-gen6
    cd nixos-image-thinkpad-t14s-gen6
    make TARGET=/dev/sdX flash

Prebuilt

    TARGET=/dev/sdX
    wget https://github.com/jollheef/nixos-image-thinkpad-t14s-gen6/releases/download/v0.2.0/nixos-thinkpad-t14s-gen6-dd5ec42.img.xz
    xz -d nixos-thinkpad-t14s-gen6-dd5ec42.img.xz
    sudo dd if=nixos-thinkpad-t14s-gen6-dd5ec42.img of=${TARGET}
    sudo partprobe
    sudo parted -sf ${TARGET} resizepart 2 100%

## Notes

- Use the front left USB-C port.
- In case of boot issues, try using a USB 2.0 to USB Type-C adapter.
- nmtui is available for managing Wi-Fi connections.
