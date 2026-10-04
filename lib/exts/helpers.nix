_: _:
let
  inherit (builtins) pathExists;
in
rec {
  # Literally equivalent to (a: a)
  identity = a: a;

  safeImport = p: d: if pathExists p then import p else d;

  safeImport' = p: safeImport p null;
}
