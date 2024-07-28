{ config, lib, options, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./kernel.nix
    ];

  hardware.firmware = [
    pkgs.linux-firmware (pkgs.callPackage ./pkgs/t14s-firmware.nix { })
  ];

  boot.loader.systemd-boot = {
    enable = true;
    extraFiles = {
      "EFI/edk2-shell/shellx64.efi" = pkgs.edk2-uefi-shell.efi;
    };
    extraEntries = {
      "edk2-shell.conf" = ''
        title edk2-shell
        efi /EFI/edk2-shell/shellx64.efi
      '';
    };
  };

  networking.networkmanager = {
    enable = true;
    plugins = lib.mkForce [];
  };

  environment.systemPackages = with pkgs; [
    parted
    cryptsetup
    nixos-install-tools

    git
    vim
    tmux

    htop
    usbutils
    pciutils
    acpi

    openssl
  ];

  services.getty.autologinUser = lib.mkDefault "root";

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = "nix-command flakes";
  };
}
