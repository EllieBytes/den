{
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.writeShellScriptBin "test" ''
  echo "hello, world!"
''
