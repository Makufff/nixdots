# If you'd saved this configuration in ./disks/default.nix, and wanted to create a disk named /dev/nvme0n1, you would run the following command to partition, format and mount the disk.
# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disks/default.nix --argstr device /dev/nvme0n1
{
  lib,
  device ? throw "Set this to your disk device, e.g. /dev/sda",
  ...
}:
{
  disko = {
    # Do not let Disko manage fileSystems.* config for NixOS.
    # Reason is that Disko mounts partitions by GPT partition names, which are
    # easily overwritten with tools like fdisk. When you fail to deploy a new
    # config in this case, the old config that comes with the disk image will
    # not boot either.
    enableConfig = false;
    devices = {
      disk.main = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "ESP";
              size = "512MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };
            swap = {
              name = "swap";
              size = "16GiB";
              type = "8200";
              content = {
                type = "swap";
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
