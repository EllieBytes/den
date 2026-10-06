{ pkgs, ... }:

{
  home.username = "user";
  home.homeDirectory = "/home/user";

  home.packages = with pkgs; [
    neovim
  ];

  home.stateVersion = "26.05";
}
