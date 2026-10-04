{
  boot.loader.grub.device = "nodev";
  fileSystems."/" = {
    device = "/dev/sda";
    fsType = "ext4";
  };
}
