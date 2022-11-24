{ stdenvNoCC, jdk, clojure, ...}:

let
  
  buildClojureLibrary = {
    pname
    ,version
    ,src
    ,path ? "src"
    ,ns ? [ pname ]
    ,deps ? []
    ,patches ? []
    , ...
  }@args : stdenvNoCC.mkDerivation (rec {
    
    inherit pname version src patches;
    
    propagatedBuildInputs = [ jdk clojure ] ++ deps;
    
    buildPhase = ''
      mkdir classes
      export CLASSPATH=$CLASSPATH:${src}/${path}
      find -name '*.java' > sources.txt
      javac @sources.txt
      java clojure.main -e "(doseq [ns '(${toString ns})] (compile ns))"
    '';    

    installPhase = ''
      mkdir -p $out/share/java
      (cd classes; jar -cf $out/share/java/${pname}-${version}.jar *)
    '';
  } // args);

in {}

