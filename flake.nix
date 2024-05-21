{
  description = "DBCaml is a database library for OCaml";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    riot = {
      url = "github:riot-ml/riot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bytestring = {
      url = "github:riot-ml/bytestring";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    serde = {
      url = "github:serde-ml/serde";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          inherit (pkgs) ocamlPackages mkShell lib;
          inherit (ocamlPackages) buildDunePackage;
          version = "0.0.2";
        in
        {
          formatter = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
          devShells = {
            default = mkShell.override { stdenv = pkgs.clang17Stdenv; } {
              buildInputs = with ocamlPackages; [
                dune_3
                ocaml
                utop
                ocamlformat
              ];
              inputsFrom = [
                self'.packages.dbcaml
                self'.packages.dbcaml_driver_postgres
                self'.packages.silo
                self'.packages.serde_postgres
              ];
              packages = builtins.attrValues {
                inherit (pkgs) clang_17 clang-tools_17 pkg-config;
                inherit (ocamlPackages) ocaml-lsp ocamlformat-rpc-lib;
              };
            };
          };
          packages = {
            randomconv = buildDunePackage {
              version = "0.2.0";
              pname = "randomconv";
              src = pkgs.fetchFromGithub {
                owner = "hannesm";
                repo = "randomconv";
                rev = "b2ce656d09738d676351f5a1c18aff0ff37a7dcc";
                sha256 = "";
              };
            };
            dbcaml = buildDunePackage {
              inherit version;
              pname = "dbcaml";
              propagatedBuildInputs = with ocamlPackages; [
                inputs'.riot.packages.default
                alcotest
                uri
              ];
              src = ./dbcaml;
            };
            dbcaml_driver_postgres = buildDunePackage {
              inherit version;
              pname = "dbcaml-driver-postgres";
              propagatedBuildInputs = with ocamlPackages; [
                inputs'.riot.packages.default
                self'.packages.dbcaml
                inputs'.bytestring.packages.default
                alcotest
                uri
                cryptokit
                self'.packages.serde_postgres
              ];
              src = ./dbcaml-driver-postgres;
            };
            serde_postgres = buildDunePackage {
              inherit version;
              pname = "serde_postgres";
              propagatedBuildInputs = with ocamlPackages; [
                inputs'.serde.packages.serde
                inputs'.serde.packages.serde_derive
                alcotest
              ];
              src = ./serde-postgres;
            };
            silo = buildDunePackage {
              inherit version;
              pname = "silo";
              propagatedBuildInputs = with ocamlPackages; [
                self'.packages.dbcaml
                self'.packages.dbcaml_driver_postgres
                self'.packages.serde_postgres
                alcotest
              ];
              src = ./silo;
            };
          };
        };
    };
}
