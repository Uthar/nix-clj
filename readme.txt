☢⚠☣ EXPERIMENTAL ☣⚠☢

These are tools for building Clojure libraries in a recreatable and traceable
way - straight from the sources - using the Nix build frameworks.

Build library:
      nix build .#clojure.pkgs.malli

Make wrapper:
     source cwp.bash
     cwp malli farolero toolsNamespace
     result/bin/clojure -e "(require 'malli.core)"

Make docker:
     source cwp.bash
     cwp+docker malli farolero toolsNamespace
     docker load < clojure-with-packages.tar.gz
     docker run -ti clojure-with-packages clojure

Make uberjar:
     source cwp.bash
     cwp+uberjar foo malli farolero toolsNamespace
     jar -tf result/share/java/foo-uberjar.jar

License:
     GPL version 3 or later
