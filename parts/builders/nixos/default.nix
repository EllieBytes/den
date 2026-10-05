{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (builtins)
    elem
    filter
    attrNames
    readDir
    ;

  candidates = [
    "hosts"
    "nixos"
  ];

  filterCandidate =
    candidate:
    if config.den.root != null then
      if elem candidate (attrNames (readDir config.den.root)) then true else false
    else
      false;

  accepted =
    if config.den.root != null then
      (map (name: config.den.root + "/${name}") (filter filterCandidate candidates))
    else
      [ ];
in
{
  config.den.builders.nixos = {
    name = "nixos";
    modules = [
      ./modules
    ];
    searchPaths = accepted;
    buildFunctions = {
      system =
        {
          name,
          meta,
          path,
          specialArgs,
          ...
        }:
        {
          nixosConfigurations."${name}" =
            let
              inherit (builtins) pathExists;

              importUser =
                name:
                if config.flake.homeConfigurations ? "${name}" then
                  { imports = (config.flake.homeConfigurations."${name}") ++ meta.home-manager.extraModules; }
                else
                  builtins.warn "User ${name} not found. Skipping import." { };

              importedUsers = lib.listToAttrs (
                map (name: {
                  inherit name;
                  value = importUser name;
                }) meta.home-manager.importUsers
              );
            in
            meta.nixpkgs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                (if pathExists (path + "/configuration.nix") then (path + "/configuration.nix") else { })
                (if meta.home-manager.enable then meta.home-manager.home-manager.nixosModules.default else { })
                (
                  if meta.home-manager.enable then
                    {
                      home-manager.enable = true;
                      home-manager.useSystemPkgs = meta.home-manager.useSystemPkgs;
                      home-manager.useUserPackages = meta.home-manager.useUserPackages;
                      home-manager.users = importedUsers // meta.home-manager.users;
                    }
                  else
                    { }
                )
                (if meta.disko.enable then meta.disko.disko.nixosModules.default else { })
                (if meta.disko.enable && (pathExists path + "/disk.nix") then (path + "/disk.nix") else { })
              ]
              ++ meta.extraModules
              ++ (lib.optionals meta.disko.enable meta.disko.extraModules);
              inherit specialArgs;
            };
        };

      deployment =
        {
          name,
          meta,
          ...
        }:
        {
          deploy.nodes."${name}" = lib.mkIf (meta.deployment.enable) {
            inherit (meta.deployment)
              hostname
              profilesOrder
              sshUser
              user
              sudo
              interactiveSudo
              sshOpts
              groups
              fastConnection
              autoRollback
              magicRollback
              tempPath
              remoteBuild
              activationTimeout
              confirmTimeout
              ;

            profiles = {
              system = {
                path =
                  meta.deployment.deploy-rs.lib."${meta.system}".activate.nixos
                    config.flake.nixosConfigurations."${name}";
              };
            }
            // meta.deployment.extraProfiles;
          };
        };
    };
  };
}
