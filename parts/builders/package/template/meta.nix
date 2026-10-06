{ inputs, ... }:

{
  # It is recommended that you specify your nixpkgs checkout.
  inherit (inputs) nixpkgs;

  # Add your supported systems here
  systems = [
    "x86_64-linux"
  ];
}
