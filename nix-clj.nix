{ stdenvNoCC, callPackage, jdk, clojure, ...}:

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
    
    inherit pname version src patches;

    nativeBuildInputs = [ jdk clojure ];
    propagatedBuildInputs = [ jdk clojure ] ++ deps;
    
    buildPhase = ''
      mkdir classes
      export CLASSPATH=$CLASSPATH:${clojure}/clojure-1.11.1.jar:${src}/${path}
      echo $CLASSPATH
      echo $clojure
      find -name '*.java' > sources.txt
      javac @sources.txt || true
      java clojure.main -e "(doseq [ns '(${toString ns})] (compile ns))"
    '';    

    installPhase = ''
      mkdir -p $out/share/java
      (cd classes; jar -cf $out/share/java/${pname}-${version}.jar *)
    '';
  } // args);

  packages = callPackage ./packages.nix { inherit buildClojureLibrary; };

in packages

