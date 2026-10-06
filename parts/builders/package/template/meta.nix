{ inputs, ... }:

{
  inherit (inputs) nixpkgs;

  # Add your supported systems here
  systems = [
    "x86_64-linux"
  ];
}
