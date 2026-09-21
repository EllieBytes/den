prov:
{ ... }:

{
  imports = [
    ./discover.nix
    ./options.nix
    ./router.nix
  ] ++ (map (name: ./builders + "/${name}")
    (builtins.attrNames (builtins.readDir ./builders)));

  _module.args.denLib = prov.lib;
}
