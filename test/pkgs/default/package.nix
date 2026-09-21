{ pkgs ? import <nixpkgs> {}, ... }:

pkgs.writeShellApplication {
  name = "test package";

  text = ''
    echo "This is a test package"
  '';
}
