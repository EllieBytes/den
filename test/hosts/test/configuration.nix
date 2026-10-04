{
  fileSystems."/" = {
    device = "/dev/sda";
    fsType = "ext4";
  };

  boot.isContainer = true;
  networking.hostName = "test-system";

  users.users.test = {
    isNormalUser = true;
    uid = 1000;
  };

  system.stateVersion = "26.05";
}
