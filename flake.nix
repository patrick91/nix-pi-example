{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    ...
  }: {
    nixosConfigurations = {
      "some-berry" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ({pkgs, ...}: {
            networking.hostName = "screenos";

            # https://github.com/NixOS/nixos-hardware/issues/631
            boot.kernelParams = ["kunit.enable=0"];
            hardware.deviceTree.filter = "bcm2711-rpi-4*.dtb";

            environment.systemPackages = with pkgs; [
              libraspberrypi
              raspberrypi-eeprom
            ];
            hardware.deviceTree.enable = true;

            hardware.raspberry-pi."4" = {
              # https://github.com/NixOS/nixos-hardware/issues/631
              fkms-3d.enable = false;
              dwc2.enable = true;
              apply-overlays-dtmerge.enable = true;
            };

            #  boot.loader.raspberryPi = {
            #    firmwareConfig = ''
            #      gpu_mem=256
            #      over_voltage=6
            #      arm_freq=2000
            #      gpu_freq=600
            #      hdmi_force_hotplug=1
            #      hdmi_group=1
            #      hdmi_mode=16
            #      hdmi_drive=2
            #    '';
            #  };

            # Use vc4-kms-v3d instead
            hardware.deviceTree.overlays = [
              #      {
              #        name = "rpivid-v4l2";
              #        dtboFile = "${pkgs.device-tree_rpi.overlays}/rpivid-v4l2.dtbo";
              #      }
              {
                name = "vc4-kms-v3d";
                dtsText = ''
                  /dts-v1/;
                  /plugin/;
                  / {
                    compatible = "brcm,bcm2711";
                    fragment@0 {
                      target = <&v3d>;
                      __overlay__ {
                        status = "okay";
                      };
                    };
                  };
                '';
              }
            ];

            fileSystems."/" = {
              device = "/dev/disk/by-label/NIXOS_SD";
              fsType = "ext4";
            };
          })
          ./hosts/some-berry/configuration.nix
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };
    };
    images = {
      "some-berry" =
        (
          self.nixosConfigurations."some-berry".extendModules {
            modules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
            ];
          }
        )
        .config
        .system
        .build
        .sdImage;
    };
  };
}
