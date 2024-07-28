{ config, lib, pkgs, ... }:

let
  inherit (config.boot.loader) efi;

  linux_x1e_pkg = { buildLinux, ... } @ args:
    buildLinux (args // rec {
      version = "6.10.0";
      modDirVersion = "6.10.0-next-20240725";

      src = pkgs.fetchFromGitLab {
        domain = "git.codelinaro.org";
        owner = "abel.vesa";
        repo = "linux";
        rev = "x1e80100-20240725"; # "x1e80100-next";
        hash = "sha256-0DFmPJEFl+cQT3Li4vuptBwavRc9CQOatd8TIYht+54=";
      };
      kernelPatches = (args.kernelPatches or [ ]);

      extraMeta.branch = "6.10";
    } // (args.argsOverride or { }));

  linux_x1e = pkgs.callPackage linux_x1e_pkg { defconfig = "x1e_defconfig"; };
  linuxPackages_x1e = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_x1e);

  dtb = "${linuxPackages_x1e.kernel}/dtbs/qcom/x1e78100-lenovo-thinkpad-t14s.dtb";
  dtbHash = builtins.hashFile "md5" dtb;
  dtbName = "x1e80100-${dtbHash}.dtb";
in {
  boot = {
    kernelPackages = linuxPackages_x1e;

    kernelParams = [
      "dtb=${dtbName}"

      #"initcall_debug"

      #"earlycon=efifb"
      "console=tty0"
      #"ignore_loglevel"
      #"keep_bootcon"

      "regulator_ignore_unused"
      "clk_ignore_unused"
      "pd_ignore_unused"
      "arm64.nopauth"
      #"acpi=no"
      "efi=novamap"
      #"efi=noruntime"

      "pcie_aspm.policy=powersupersave"
      "iommu.strict=0"
      "iommu.passthrough=0"

      #"earlyprintk=xdbc"
      #"usbcore.autosuspend=-1"
      "module_blacklist=edac_core,qcom_q6v5_pas"
    ];

    supportedFilesystems.zfs = false;

    initrd = {
      includeDefaultModules = false;

      availableKernelModules = [
        "nvme"
        "uas"
        "usb-storage"

        "gpio-sbu-mux"
        "leds-qcom-lpg"
        "msm"
        "panel-edp"
        "pmic-glink-altmode"
        "pwm-bl"
        "qrtr"

        "i2c-core"
        "i2c-hid"
        "i2c-hid-of"
        "i2c-qcom-geni"

        "phy-qcom-edp"
        "phy-qcom-eusb2-repeater"
        "phy-qcom-qmp-combo"
        "phy-qcom-qmp-pcie"
        "phy-qcom-qmp-usb"
        "phy-qcom-snps-eusb2"
        "phy-qcom-snps-femto-v2"
        "phy-qcom-usb-hs"

        "dispcc-x1e80100"
        "gpucc-x1e80100"
        "tcsrcc-x1e80100"

        # fat32
        "vfat" "nls-cp437" "nls-iso8859-1"
      ];

      systemd = {
        enable = true;
        enableTpm2 = false;
      };
    };

    loader = {
      systemd-boot.enable = lib.mkForce true;
      efi.canTouchEfiVariables = false;
      systemd-boot.extraFiles = {
        "${dtbName}" = dtb;
      };
    };
  };

  system.activationScripts.t14s-gen6-dtb = ''
    in_package="${dtb}"
    esp_tool_folder="${efi.efiSysMountPoint}/"
    in_esp="''${esp_tool_folder}${dtbName}"
    in_esp_backup="''${esp_tool_folder}/dtb/${dtbName}"
    in_esp_backup_dir="''${esp_tool_folder}/dtb/"
    mkdir -p "$in_esp_backup_dir"
    cp "$in_package" "$in_esp_backup"
    >&2 echo "Ensuring $in_esp in EFI System Partition"
    if ! ${pkgs.diffutils}/bin/cmp --silent "$in_package" "$in_esp"; then
      >&2 echo "Copying $in_package -> $in_esp"
      mkdir -p "$esp_tool_folder"
      cp "$in_package" "$in_esp"
      sync
    fi
  '';
}
