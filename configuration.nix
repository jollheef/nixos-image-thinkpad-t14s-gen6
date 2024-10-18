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

  boot.loader.efi.canTouchEfiVariables = false;
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

  nixpkgs.overlays = [
    (final: prev: {
      qrtr = prev.callPackage ./pkgs/qrtr.nix {};
      qmic = prev.callPackage ./pkgs/qmic.nix {};
      rmtfs = prev.callPackage ./pkgs/rmtfs.nix { inherit (final) qrtr qmic; };
      pd-mapper = final.callPackage ./pkgs/pd-mapper.nix { inherit (final) qrtr; };
    })
  ];

  systemd.services = {
    pd-mapper = {
      unitConfig = {
        Requires = "qrtr-ns.service";
        After = "qrtr-ns.service";
      };
      serviceConfig = {
        Restart = "always";
        ExecStart = "${pkgs.pd-mapper}/bin/pd-mapper";
      };
      wantedBy = [
        "multi-user.target"
      ];
    };
    qrtr-ns = {
      serviceConfig = {
        ExecStart = "${pkgs.qrtr}/bin/qrtr-ns -v -f 1";
        Restart = "always";
      };
      wantedBy = ["multi-user.target"];
    };
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = "nix-command flakes";
  };
}
