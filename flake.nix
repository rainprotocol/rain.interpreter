{
  description = "Flake for development workflows.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainprotocol/rainix/53a66f55c1875bfdbd819bbfc3553501b08c602f";
  };

  outputs = { self, flake-utils, rainix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
      in {
        packages = rec {
          i9r-prelude = rainix.mkTask.${system} {
            name = "i9r-prelude";
            body = ''
              set -euxo pipefail

              # Needed by deploy script.
              mkdir -p deployments/latest;

              # Build metadata that is needed for deployments.
              mkdir -p meta;
              rain meta build \
                -i <(forge script --silent ./script/BuildAuthoringMeta.sol && cat ./meta/AuthoringMeta.rain.meta) \
                -m authoring-meta-v1 \
                -t cbor \
                -e deflate \
                -l none \
                -o meta/RainterpreterExpressionDeployerNPE2.rain.meta \
              ;
            '';
            additionalBuildInputs = rainix.sol-build-inputs.${system};
          };
        } // rainix.packages.${system};

        devShells = rainix.devShells.${system};
      }
    );
}