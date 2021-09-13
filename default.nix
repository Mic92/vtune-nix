with import <nixpkgs> {};

let
  vtune = callPackage ./vtune.nix {};
in
stdenv.mkDerivation {
  name = "vtune-shell";
  buildInputs = [
    vtune
  ];
}
