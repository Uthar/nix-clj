{
  description = "Utilities for packaging Clojure libraries";

  outputs = { self, nixpkgs, flake-utils, dev }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        devpkgs = dev.packages.${system};
        clojurePackages = pkgs.callPackage ./nix-clj.nix {
          inherit (devpkgs) clojure jdk;
        };
      in
      {
        packages = { inherit (clojurePackages) farolero macrovich; };
      });
}
