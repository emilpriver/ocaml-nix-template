{
  description = "Nix and Ocaml template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    riot = {
      url = "github:emilpriver/riot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          inherit (pkgs) ocamlPackages mkShell;
          inherit (ocamlPackages) buildDunePackage;
          version = "0.0.1+dev";
        in
        {
          devShells = {
            default = mkShell {
              buildInputs = [
                ocamlPackages.dune_3
                ocamlPackages.ocaml
                ocamlPackages.utop
                ocamlPackages.ocamlformat
                ocamlPackages.ounit2
              ];
              inputsFrom = [
                self'.packages.default
              ];
              packages = builtins.attrValues {
                inherit (pkgs) clang_17 clang-tools_17 pkg-config;
                inherit (ocamlPackages) ocaml-lsp ocamlformat-rpc-lib;
              };
              dontDetectOcamlConflicts = true;
            };
          };
          packages = {
            default = buildDunePackage {
              inherit version;
              pname = "nix_template";
              propagatedBuildInputs = [
                inputs'.riot.packages.default
              ];
              src = ./.;
              buildPhase = ''
                dune build
              '';
              doCheck = true;
              installPhase = ''
                mkdir $out
                cp _build/default/bin/main.exe $out
              '';
            };
            test = pkgs.stdenv.mkDerivation {
              name = "ocaml-test";
              buildInputs = [
                ocamlPackages.dune_3
                ocamlPackages.ocaml
                ocamlPackages.utop
                ocamlPackages.ocamlformat
                ocamlPackages.ounit2
              ];
              inputsFrom = [
                self'.packages.default
              ];
              src = ./.;
              buildPhase = ''
                dune runtest
              '';
              doCheck = true;
              ## Create and output the result. for instance the coverage.txt
              installPhase = ''
                mkdir -p $out
                touch $out/coverage.txt
                echo "I am the coverage of the test" > $out/coverage.txt 
              '';
            };
            dockerImage = pkgs.dockerTools.buildLayeredImage {
              name = "nix-template";
              tag = "0.0.1+dev";
              contents = [ self'.packages.default ocamlPackages.ounit2 ];
              config = {
                Cmd = [ "${self'.packages.default}/bin/main.exe" ];
                ExposedPorts = { "8000/tcp" = { }; };
                Env = [
                  ("GITHUB_SHA=123123")
                ];
              };
            };
          };
          formatter = pkgs.nixpkgs-fmt;
        };
    };
}
