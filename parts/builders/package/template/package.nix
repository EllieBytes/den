{
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.writeShellScriptBin "hello" ''
  echo "Hello, World!"
''
