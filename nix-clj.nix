{ stdenvNoCC, callPackage, makeBinaryWrapper, applyPatches, jdk, clojure, ...}:

let
  
  buildClojureLibrary = {
    pname
    ,version
    ,src
    ,path ? "src"
    ,ns ? [ "${pname}.core" ]
    ,deps ? []
    ,patches ? []
    , ...
  }@args : stdenvNoCC.mkDerivation (rec {
    
    inherit pname version;

    nativeBuildInputs = [ jdk clojure ];
    propagatedBuildInputs = [ jdk clojure ] ++ deps;

    # Clojure libraries seem to be usually built with deps.edn or Leiningen.
    #
    # I don't want to work with deps.edn, because it is hard-coded to make
    # network requests on runtime. (Tried patching that out, but gave up, didn't
    # dig too deep and don't remember what was blocking me... only remember it
    # being something seemingly arbitrary - and some problems with it's fetching
    # of git repositories).
    #
    # I remeber considering Leiningen, but discarding it because of
    # bootstrapability issues - Leiningen is build using Leiningen. I tried
    # compiling old versions from scratch but gave up after getting no real
    # results.
    #
    # But maybe that's not a problem? Since the main thing that these tools are
    # doing is exporting a classpath (after pulling binary blobs from maven), I
    # can easily do it by hand. Here is a summary of the buildPhase:
    #
    # 1. Some libraries contain a little Java source code. Compile that first
    #    (since the Clojure code might depend on that)
    # 2. Now compile each namespace with clojure.core/compile.
    #
    # For that to work, some things need to happen:
    #
    # - A target directory for bytecode must exist. Default for Clojure is
    #   "classes" - It's no problem to share it with any Java-produced code.
    # - Any classes referenced in code must be present on the class path. Same
    #   for required Clojure namespaces - clojure.core/require looks for that on
    #   the classpath.
    #
    # Notes on the installPhase:
    #
    # - my Clojure doesn't seem to use the precombiled
    #   bytecodes. It insists on always loading the source files, even when the
    #   bytecode exists alongside it on the filesystem. I deduce this from the
    #   clojure.core/require calls being just as slow. I might be doing something
    #   wrong here... didn't dig into it too much. But decided to just prune the
    #   sources from the uberjar, leaving only the bytecode. This was immediately
    #   visible by loading being an order of magnitude faster.
    # - Put the jar in $out/share/java for it to be found by nixpkgs setup hooks.

    # TODO maybe use clojure.lang.Compile
    buildPhase = let
      src' = if builtins.length patches > 0
             then applyPatches { inherit src patches; }
             else src;
    in ''
      mkdir classes
      export CLASSPATH=$CLASSPATH:${src'}/${path}:classes
      find -name '*.java' > sources.txt
      javac -d classes @sources.txt || true
      java clojure.main -e "(doseq [ns '(${toString ns})] (compile ns))"
    '';    

    installPhase = ''
      mkdir -p $out/share/java
      (cd classes; jar -cf $out/share/java/${pname}-${version}.jar *)
    '';
  } // args);

  clojureWithPackages = selectPackages: stdenvNoCC.mkDerivation {
    pname = "clojure";
    version = "with-packages";
    dontUnpack = true;
    buildInputs = [ makeBinaryWrapper ];
    propagatedBuildInputs = selectPackages packages;
    installPhase = ''
      makeWrapper ${jdk}/bin/java $out/bin/clojure \
        --add-flags clojure.main \
        --prefix CLASSPATH : "$CLASSPATH"
    '';
  };

  packages = callPackage ./packages.nix { inherit buildClojureLibrary; };

  buildUberjar = pname: cljpkgs: stdenvNoCC.mkDerivation {
    inherit pname;
    version = "uberjar";
    propagatedBuildInputs = cljpkgs;
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/java
      mkdir classes
      jars=$(echo $CLASSPATH | sed 's,:, ,g')
      for jar in $jars; do
        (cd classes; jar -xf $jar)
      done
      (cd classes; jar -cf $out/share/java/$name.jar *)
    '';
  };

in clojure // {
  pkgs = packages;
  withPackages = clojureWithPackages;
  inherit
    buildClojureLibrary
    buildUberjar
  ;
}

