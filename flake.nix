{
  description = "My site :3";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    hugo-blowfish = {
      url = "github:nunocoracao/blowfish";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, hugo-blowfish }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "website";
          src = self;
          buildInputs = [ pkgs.git pkgs.hugo pkgs.nodePackages.prettier ];
          buildPhase = ''
            mkdir -p themes
            ln -s ${inputs.hugo-blowfish} themes/hugo-blowfish
            ${pkgs.hugo}/bin/hugo
            ${pkgs.nodePackages.prettier}/bin/prettier -w public '!**/*.{js,css}'
          '';
          installPhase = "cp -r public $out";
        };
        devShell = pkgs.mkShell { buildInputs = [ pkgs.hugo ]; };
      });
}
