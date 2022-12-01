☢⚠☣ EXPERIMENTAL ☣⚠☢

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

License:
     GPL version 3 or later
