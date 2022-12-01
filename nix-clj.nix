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
    
    buildPhase = let
      src' = if builtins.length patches > 0
             then applyPatches { inherit src patches; }
             else src;
    in ''
      mkdir classes
      export CLASSPATH=$CLASSPATH:${clojure}/clojure-1.11.1.jar:${src'}/${path}:classes
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
        --prefix CLASSPATH : "$CLASSPATH" \
        --prefix CLASSPATH : "${clojure}/clojure-1.11.1.jar"
    '';
  };

  packages = callPackage ./packages.nix { inherit buildClojureLibrary; };

in clojure // {
  pkgs = packages;
  withPackages = clojureWithPackages;
}

