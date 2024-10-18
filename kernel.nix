{ config, lib, pkgs, ... }:

let
  linux_x1e_pkg = { buildLinux, ... } @ args:
    buildLinux (args // rec {
      version = "6.12.0";
      modDirVersion = "6.12.0-rc3";

      src = pkgs.fetchFromGitHub {
        owner = "jhovold";
        repo = "linux";
        # wip/x1e80100-6.12-rc3
        rev = "84318c8e3038f579070e7c5d109d1d2311a5f437";
        hash = "sha256-kpuzjqcI4YGS+S9OvIUhm6z8xCGMA5h5+JlcHhoEETM=";
      };
      kernelPatches = (args.kernelPatches or [ ]);

      extraMeta.branch = "6.12";
    } // (args.argsOverride or { }));

  linux_x1e = pkgs.callPackage linux_x1e_pkg {
    defconfig = "johan_defconfig";
  };

  linuxPackages_x1e = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_x1e);

in {
  hardware = {
    deviceTree = {
      enable = true;
      name = "qcom/x1e78100-lenovo-thinkpad-t14s.dtb";
    };
  };

  boot = {
    kernelPackages = linuxPackages_x1e;

    kernelPatches = [
      {
        name = "backlight";
        patch = ./patches/backlight.patch;
      }
      {
        name = "bluetooth";
        patch = ./patches/bluetooth.patch;
      }
      {
        name = "disable-type-c-dp";
        patch = ./patches/disable-type-c-dp.patch;
      }
      {
        name = "vmlinuz.efi";
        patch = null;
        extraStructuredConfig = with lib.kernel; {
          EFI_ZBOOT = lib.mkForce no;
        };
      }
      {
        name = "disable-qr-code-panic-screen";
        patch = null;
        extraStructuredConfig = with lib.kernel; {
          DRM_PANIC_SCREEN_QR_CODE = lib.mkForce no;
        };
      }
      {
        name = "disable-rust";
        patch = null;
        extraStructuredConfig = with lib.kernel; {
          RUST = lib.mkForce no;
        };
      }
    ];

    kernelParams = [
      "regulator_ignore_unused"
      "clk_ignore_unused"
      "pd_ignore_unused"
      "arm64.nopauth"
      "efi=novamap"
      "pcie_aspm.policy=powersupersave"
      "iommu.strict=0"
      "iommu.passthrough=0"
    ];

    supportedFilesystems.zfs = false;

    initrd = {
      systemd = {
        enable = true;
        tpm2.enable = false;
      };

      includeDefaultModules = false;

      availableKernelModules = [
        "nvme"
        "uas"
        "usb-storage"
        "pcie-qcom"

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
    };
  };
}
