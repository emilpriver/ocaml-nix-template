{
  description = "Nix and Ocaml template";

  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
  };

  outputs = inputs@{ flake-parts,nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          pkgs = nixpkgs.legacyPackages."${system}".extend (self: super: {
            ocamlPackages = super.ocaml-ng.ocamlPackages_5_1;
          });
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
            #randomconv = buildDunePackage {
            #  version = "0.2.0";
            #  pname = "randomconv";
            #  src = pkgs.fetchFromGitHub {
            #    owner = "hannesm";
            #    repo = "randomconv";
            #    rev = "b2ce656d09738d676351f5a1c18aff0ff37a7dcc";
            #    hash = "sha256-KIvx/UNtPTg0EqfwuJgzSCtr6RgKIXK6yv9QkUUHbJk=";
            #  };
            #  dontDetectOcamlConflicts = true;
            # };
            default = buildDunePackage {
              inherit version;
              pname = "nix_template";
              buildInputs = [
              # self'.packages.random
              ];
              src = ./.;
              buildPhase = ''
                dune build
              '';
              doCheck = true;
              dontDetectOcamlConflicts = true;
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
