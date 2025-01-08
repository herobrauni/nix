{
  inputs,
  config,
  ...
}: {
  imports = [inputs.disko.nixosModules.disko];
  disko.devices = {
    disk = {
      main = {
        device = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
              };
            };
            root = {
              name = "root";
              size = "10G";
              content = {
                type = "lvm_pv";
                vg = "vg-root";
              };
            };
            storage = {
              name = "storage";
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "lvm-storage";
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      vg-root = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
      "lvm-storage" = {
        type = "lvm_vg";
      };
    };
  };
}
