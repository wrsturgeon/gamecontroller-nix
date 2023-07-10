{
  description = "RoboCup SPL Legacy GameController (2022 & earlier)";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    gamecontroller = { url = "github:robocup-spl/gamecontroller"; flake = false; };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, flake-utils, gamecontroller, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
      ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "robocup-spl-gamecontroller";
          version = "2022";
          src = gamecontroller;
          buildInputs = with pkgs; [ ant jdk makeWrapper ];
          buildPhase = ''
            ln -s $(which java) $out/java
            ant
            mv ./bin $out
          '';
          installPhase = ''
            set -eux
            for jar in $out/*.jar
            do
              echo "cd $out && java -jar $jar" > $jar.sh
              chmod +x $jar.sh
              wrapProgram $jar.sh --set PATH ${nixpkgs.lib.makeBinPath [ pkgs.jdk ]}
            done
          '';
        };
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/GameController.jar.sh";
        };
      }
    );
}
