{
  config,
  lib,
  denLib,
  ...
}:
let
  inherit (builtins) attrNames;
in
{
  config.den.builders.nixos = {
    name = "nixos";
    modules = [
      ./modules
    ];

    searchPaths = (
      denLib.fs.allPathsPresentIn [
        "hosts"
        "nixos"
        "nixosConfigurations"
        "systems"
      ] config.den.root
    );

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
              inherit (builtins)
                pathExists
                head
                tail
                isString
                filter
                split
                warn
                ;

              bestUser =
                name: host:
                let
                  users = attrNames (config.flake.homeConfigurations or { });
                  separated =
                    let
                      splitNames = map (user: filter isString (split "^.*@.*$" user)) users;
                    in
                    map (sep: {
                      name = head sep;
                      host = tail sep;
                    }) splitNames;

                  candidates = map (x: {
                    inherit (x) name;
                    host = if x.host == [ ] then null else head x.host;
                  }) separated;

                  bests = filter (x: x.name == name && x.host == host) candidates;
                  secondBests = filter (x: x.name == name) candidates;

                  best =
                    if bests != [ ] then
                      head bests
                    else if secondBests != [ ] then
                      head secondBests
                    else
                      warn "Could not find acceptable home-manager candidate for ${name}@${host}" { };
                in
                best;

              importedUsers = lib.listToAttrs (
                map (name: {
                  inherit name;
                  value = bestUser name meta.hostname;
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
                      home-manager.useGlobalPkgs = meta.home-manager.useGlobalPkgs;
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

    meta = {
      version = "0.1.0-alpha";
      template = ./template;
      authors = [ "Ellie Johnston <jellie7118@proton.me>" ];
      description = ''
        Produces a nixos configuration, and a deploy-rs node associated with it.

        Optional additions (features)
          => disko
          => home-manager
          => deploy-rs
          => agenix

        system => nixosConfigurations.<name>
        deployment => deploy.nodes.<name>
      '';
    };
  };
}
