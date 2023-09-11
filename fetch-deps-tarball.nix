# { hash, src,4 ... }:
{ pkgs ? import <nixpkgs> {}, ... }:

let
  fetchDepsEdnTarball = { src, m2Sha256 }:

    pkgs.stdenvNoCC.mkDerivation {

      outputHashMode = "flat";
      outputHashAlgo = "sha256";
      outputHash = m2Sha256;

      pname = "deps.edn";
      version = "m2";
      inherit src;

      nativeBuildInputs = with pkgs; [
        tree
        leiningen
        git
        cacert
      ];

      buildPhase = ''
        make_deterministic_repo(){
          local repo="$1"
          (
          cd "$repo"
          git config pack.threads 1
          git repack -A -d -f
          git gc --prune=all --keep-largest-pack
          )
        }

        export SOURCE_DATE_EPOCH=1
        export HOME=$(pwd)
        clojure -P

        tree -a /build/.m2/

        # contains impure timestamp
        find /build/.m2 -name _remote.repositories -exec rm -v {} \; || true

        find /build/.gitlibs -name .git -type f | while read -r repoGit; do
          make_deterministic_repo "$(dirname "$repoGit")"
        done

        find /build/.gitlibs -name worktrees -type d -exec rm -rv {} \; || true
      '';


      installPhase = ''
        ls -lah .
        ls -lah /build
        tar --owner=0 --group=0 --numeric-owner --format=gnu \
            --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
            -czf $out /build/.m2 /build/.gitlibs
      '';
      
    };

  fetchLeiningenTarball = { src, m2Sha256 }:

    pkgs.stdenvNoCC.mkDerivation {

      outputHashMode = "flat";
      outputHashAlgo = "sha256";
      outputHash = m2Sha256;

      pname = "m2";
      version = "tarball";
      inherit src;

      nativeBuildInputs = with pkgs; [
        tree
        leiningen
        cacert
      ];

      buildPhase = ''
        export SOURCE_DATE_EPOCH=1
        export HOME=$(pwd)

        lein deps

        tree -a /build/.m2/

        cat /build/.m2/repository/org/postgresql/postgresql/42.6.0/_remote.repositories

        # contains impure timestamp
        find /build/.m2 -name _remote.repositories -exec rm -v {} \; || true
      '';


      installPhase = ''
        ls -lah .
        ls -lah /build
        tar --owner=0 --group=0 --numeric-owner --format=gnu \
            --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
            -czf $out /build/.m2
      '';
      
    };

  buildClojurePackage = { pname, version, src, m2Sha256 }:
    let
      m2 = fetchDepsEdnTarball { inherit src m2Sha256; };      
    in pkgs.stdenvNoCC.mkDerivation {
      inherit pname version src;
      passthru = { inherit m2; };
      buildInputs = with pkgs; [
        clojure
        git
        tree
      ];
      buildPhase = ''
        mkdir classes
        export HOME=$(pwd)
        mkdir $HOME/.m2
        tar -C /build --strip-components=1 -xf ${m2}
        ls -lah
        export GITLIBS_DEBUG=1
        clojure -e "(compile 'foo)"
      '';
      installPhase = ''
        mkdir -pv $out
        cp -r * $out
      '';
    };

  buildClojurePackage2 = { pname, version, src, m2Sha256 }:
    let
      m2 = fetchLeiningenTarball { inherit src m2Sha256; };      
    in pkgs.stdenvNoCC.mkDerivation {
      inherit pname version src;
      passthru = { inherit m2; };
      buildInputs = with pkgs; [
        leiningen
        git
        tree
      ];
      buildPhase = ''
        mkdir classes
        export HOME=$(pwd)
        mkdir $HOME/.m2
        tar -C /build --strip-components=1 -xf ${m2}
        ls -lah
        lein run -m clojure.main -c "(compile 'foo)"
      '';
      installPhase = ''
        mkdir -pv $out
        cp -r * $out
      '';
    };

# in buildClojurePackage {
#   pname = "test";
#   version = "test";
#   src = ./.;
#   # m2Sha256 = "sha256-PGtBTUE/A6zEpasnmxRuzMnOCjGq2hsgCkHg3M5ZiAQ=";
#   m2Sha256 = "";
# }

in { inherit fetchLeiningenTarball buildClojurePackage2; }
