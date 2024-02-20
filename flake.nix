{
  description = "Utilities for packaging Clojure libraries";

  outputs = { self, nixpkgs, flake-utils, dev }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        devpkgs = dev.packages.${system};
        lib = nixpkgs.lib;
        clojure = pkgs.callPackage ./nix-clj.nix {
          inherit (devpkgs) clojure jdk;
        };
        java = pkgs.callPackage ./java.nix {
          inherit (devpkgs) jdk;
        };
        mavenBootstrap = pkgs.callPackage ./mavenBootstrap.nix {
          inherit (devpkgs) jdk;
        };
      in {

        packages.mavenBootstrap = mavenBootstrap;

        packages.zstd = pkgs.zstd;
        packages.brotli = pkgs.brotli;
                
        packages.clojure = clojure;

        packages.java = java;

        packages.maven = pkgs.maven;

        packages.cider = clojure.buildUberjar "cider" [
          clojure.pkgs.nrepl
          clojure.pkgs.ciderNrepl
        ];
        
      });
}
