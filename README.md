# Den

<img src="./assets/logo.svg" width="256" height="256" alt="assets/logo.svg"/>

Make your Nix flake easier to manage.

> [!WARNING]
> This stuff is incomplete, but partially ready for use.
> Do not expect stability or ease of use.

## Why Den?

Den was designed by me to solve every problem I have with Nix Flake auto-discovery systems. (e.g. snowfall).

Den is made to be as flexible as possible.

## Builders in Den.

Builders are located at `config.builders`

Builders are the primitive that really make Den work. Without them Den doesn't do much.
Builders are extensible and overridable by default.

#### Builder Structure.
```Nix
# Note: The word "output" refers to an attrset of multiple flake outputs, and not just 1 flake output.
#       However, it is preferred that each build funciton produce only 1 flake output.

{
  # Name of this builder.
  name = "";

  # List of modules to evaluate before the discovered meta.nix files.
  modules = [];

  # Paths for this builder to search in
  searchPaths = [];

  # set of functions that build 1 output for each discovered object.
  buildFunctions = {};

  # set of functions that aggregate every output of this builder into one.
  aggregateFunctions = {};

  # metadata for this builder, meant for the CLI tool.
  meta = {
    # Version, does nothing yet, eventually builders will be for a specific den version.
    # null or string.
    version = null;

    # Optional path to a template build object.
    # This will be used by `den add <name> <builder>`
    template = null;

    # List of the authors of this builder.
    authors = [];

    # Description of this builder.
    description = "";
  };
}
```


#### Example Build Function.

```Nix
{ 
  name,        # Name of the object being built.
  meta,        # Final meta.nix output of this object.
  path,        # The path this object was found in.
  specialArgs, # specialArgs passed to lib.discoverGenerics
}: {
  # Anything placed in here is mapped directly to `config.flake`
  # Example package.
  package.${meta.system}.${name} = meta.pkgs.callPackage (path + "/package.nix"); 
}
```

#### Example Aggregate Functions.
```Nix
# The outputs of this builder only, these are not flake-wide outputs.
outputs: {
  overlays.default = (final: prev: outputs.packages."x86_64-linux" or {});
}
```
