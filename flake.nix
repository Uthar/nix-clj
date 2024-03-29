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
      in {
        
        packages.clojure = clojure;

        packages.cider = clojure.buildUberjar "cider" [
          clojure.pkgs.nrepl
          clojure.pkgs.ciderNrepl
        ];
        
      });
}
