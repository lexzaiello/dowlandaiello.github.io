{
  description = "My site :3";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    hugo-terminal = {
      url = "github.com:panr/hugo-theme-terminal";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, hugo-terminal }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "website";
          src = self;
          buildInputs = [ pkgs.git pkgs.hugo pkgs.nodePackages.prettier ];
          buildPhase = ''
            mkdir -p themes
            ln -s ${inputs.hugo-terminal} themes/terminal
            ${pkgs.hugo}/bin/hugo --gc --minify
            ${pkgs.nodePackages.prettier}/bin/prettier -w public '!**/*.{js,css}'
          '';
          installPhase = "cp -r public $out";
        };
        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.hugo ];
          shellHook = ''
            mkdir -p themes
            ln -s ${inputs.hugo-terminal} themes/terminal
          '';
        };
      });
}
