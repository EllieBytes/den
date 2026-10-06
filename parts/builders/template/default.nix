{ config, denLib, ... }:

{
  den.builders.template = {
    name = "template";
    searchPaths =
      if config.den.root != null then
        denLib.fs.allPathsPresentIn [ "templates" ] config.den.root
      else
        [ ];

    modules = [
      ./modules
    ];

    buildFunctions.template =
      {
        name,
        path,
        meta,
        ...
      }:
      {
        templates."${name}" = {
          path = if meta.entrypoint == null then (path + "/template") else meta.entrypoint;
          inherit (meta) description;
          welcomeText = meta.message;
        };
      };

    meta.template = ./template;
    meta.authors = [ "Ellie Johnston <jellie7118@proton.me>" ];
  };
}
