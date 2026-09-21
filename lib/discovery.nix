{ inputs, lib, ... }:

let
  lib' = lib;
  inherit (lib) fs;
  inherit (builtins) pathExists filter warn listToAttrs;
in rec {
  # discoverGenerics
  # :: {
  #   baseMeta :: Submodule,
  #   lib :: Lib,
  #   specialArgs :: Attrs
  # }
  # -> Path
  # -> { _ :: { name :: String, path :: Path, meta :: Attrs, specialArgs :: Attrs } }
  #
  # Discovers all items within a directory.
  discoverGenerics = {
    baseMetas ? [],
    lib ? lib',
    specialArgs ? {},
  }: dir: let
    topLevelMeta =
      if pathExists (dir + "/meta.nix") then
        import (dir + "/meta.nix")
      else {};

    handleSubpath = subdir: name:
      let
        foundMeta =
          if pathExists (subdir + "/meta.nix") then
            import (subdir + "/meta.nix")
          else warn "No meta.nix found for item ${name} at ${subdir}." {};

        meta = (lib.evalModules {
          modules =
            baseMetas
            ++ [
              topLevelMeta
              foundMeta
            ];

          specialArgs = {
            inherit lib name inputs;
            path = subdir;
          } // specialArgs;
        }).config;
      in { inherit name meta specialArgs; path = subdir; };

    found =
      map (name: { inherit name; path = dir + "/${name}"; })
        (filter (x: !(fs.isHidden x)) (fs.subdirNames dir));
  in listToAttrs (map ({ name, path }: { inherit name; value = handleSubpath path name; }) found);

  discoverGenerics' = {
    baseMetas ? [],
    lib ? lib',
    specialArgs ? {},
  } dir:
    let
      # Thin appendix to the meta eval list.
      # It still will not evaluate top level meta.nix files.
      # USE `discoverGenerics` IF THAT IS YOUR GOAL!!
      warning = if pathExists (dir + "/meta.nix") then
        (warn ''
          discoverGenerics': found top level meta in `${dir}`.
          This variant will not evaluate it.
          Did you mean to use `discoverGenerics`?
        '' []) else [];

      handleSubpath = subdir: name:
        let
          foundMeta =
            if pathExists (subdir + "/meta.nix") then
              import (subdir + "/meta.nix")
            else warn "No meta.nix found for item ${name} at ${subdir}." {};

          meta = (lib.evalModules {
            modules = warning
              ++ baseMetas
              ++ [
                foundMeta
              ];

            specialArgs = {
              inherit lib name inputs;
              path = subdir;
            } // specialArgs;
          }).config;
        in { inherit name meta specialArgs; path = subdir; };

      found =
        map (name: { inherit name; path = dir + "/${name}"; })
          (filter (x: !(fs.isHidden x)) (fs.subdirNames dir));
      in listToAttrs (map ({ name, path }: { inherit name; value = handleSubpath path name; }) found);


  discoverGeneric = {
    baseMetas ? [],
    lib ? lib',
    specialArgs ? {},
    name ? null,
  }: dir: let
    foundMeta = if pathExists (dir + "/meta.nix") then
      import (dir + "/meta.nix")
    else
      warn "No meta.nix found in ${dir}" {};

    meta = (lib.evalModules {
      modules =
        baseMetas
        ++ [
          foundMeta
        ];

      specialArgs = {
        inherit lib inputs;
        path = dir;
        name =
          if name != null then
            (warn ''
              Meta intended for path-level attempting to access `name`.
              Keep in mind that path-level metas are not allowed to have names.
            '' "(top)")
          else name;
      } // specialArgs;
    }).config;
  in { inherit name meta specialArgs; path = dir; };
}
