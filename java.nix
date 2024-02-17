{ stdenv, stdenvNoCC, lib, pkgs, fetchFromGitLab, fetchFromGitHub, fetchzip, jdk, ant, ... }:

# TODO: maven is not bootstrapped in Nixpkgs - but it is in Guix - copy them.

# TODO: Java is also not bootstrapped. Can bootstrap with jikes/gnu classpath...

let

  #### Maven 3.3.9 bootstrap beginning

  # To start off bootstrapping maven 3.3.9, open its pom.xml file at the root of
  # the repository to see what it depends on (the <dependencies> tag).
  #
  # Following are dependencies as defined in pom.xml

  mavenVersion = "3.3.9";
  classWorldsVersion = "2.5.2";
  commonsCliVersion = "1.2";
  commonsLangVersion = "3.4";
  junitVersion = "4.11";
  plexusVersion = "1.6";
  plexusInterpolationVersion = "1.21";
  plexusUtilsVersion = "3.0.22";
  guavaVersion = "18.0";
  guiceVersion = "4.0";
  sisuInjectVersion = "0.3.2";
  wagonVersion = "2.10";
  securityDispatcherVersion = "1.3";
  cipherVersion = "1.7";
  modelloVersion = "1.8.3";
  jxpathVersion = "1.3";
  aetherVersion = "1.13.1"; # NOTE: newer than in pom.xml
  slf4jVersion = "1.7.5";

  buildJar = args@{
    pname, version, src
    , dependencies ? []
    , paths ? ["src/main/java"]
    , javacFlags ? "--release 8"
    , ...
  }: stdenvNoCC.mkDerivation ({
    inherit pname version src;
    nativeBuildInputs = [ jdk ] ++ dependencies;
    propagatedBuildInputs = dependencies;
    buildPhase = ''
      javac ${javacFlags} -encoding utf-8 -d classes $(find ${lib.concatStringsSep " " paths} -type f -name '*.java')
    '';
    installPhase = ''
      mkdir -p $out/share/java
      jar --date=1980-01-01T00:00:02Z --create --file $out/share/java/${pname}-${version}.jar -C classes .
      runHook postInstall
    '';
  } // args);

  mavenDeps = rec {

  # Maven Modules
  mavenSource = fetchFromGitHub {
    owner = "apache";
    repo = "maven";
    rev = "maven-${mavenVersion}";
    hash = "sha256-qqk0FyPo0X43d9Co7qe193D9lIj6DbJ7Tu7WGoD5QkY=";
  };
    
  maven-model = buildJar {
    pname = "maven-model";
    version = mavenVersion;
    src = mavenSource;
  };

  maven-settings = buildJar {
    pname = "maven-settings";
    version = mavenVersion;
    src = mavenSource;
  };

  maven-settings-builder = buildJar {
    pname = "maven-settings-builder";
    version = mavenVersion;
    src = mavenSource;
  };

  maven-plugin-api = buildJar {
    pname = "maven-plugin-api";
    version = mavenVersion;
    src = mavenSource;
  };

  maven-embedder = buildJar {
    pname = "maven-embedder";
    version = mavenVersion;
    src = mavenSource;
  };

  maven-core = buildJar {
    pname = "maven-core";
    version = mavenVersion;
    src = mavenSource;
  };

  maven-model-builder = buildJar {
    pname = "maven-model-builder";
    version = mavenVersion;
    src = mavenSource;
  };

  maven-compat = buildJar {
    pname = "maven-compat";
    version = mavenVersion;
    src = mavenSource;
  };

  maven-artifact = buildJar {
    pname = "maven-artifact";
    version = mavenVersion;
    src = mavenSource;
  };

  maven-aether-provider = buildJar {
    pname = "maven-aether-provider";
    version = mavenVersion;
    src = mavenSource;
  };

  maven-repository-metadata = buildJar {
    pname = "maven-repository-metadata";
    version = mavenVersion;
    src = mavenSource;
  };

  maven-builder-support = buildJar {
    pname = "maven-builder-support";
    version = mavenVersion;
    src = mavenSource;
  };

  # Plexus
  plexus-utils = buildJar {
    pname = "plexus-utils";
    version = plexusUtilsVersion;
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-utils";
      rev = "plexus-utils-${plexusUtilsVersion}";
      hash = "sha256-zIAOq363FTLcLw4WJ90nXNsikavVXKGHVskS+TzH1o4=";
    };
  };

  # Guava
  jsr-305 = buildJar rec {
    pname = "jsr-305";
    version = "1.3.9";
    src = fetchzip {
      # TODO there is a -src artifact on central
      url = "mirror://maven/com/google/code/findbugs/jsr305/${version}/jsr305-${version}-sources.jar";
      hash = "";
    };
  };

  guava = buildJar {
    pname = "guava";
    version = guavaVersion;
    src = fetchFromGitHub {
      owner = "google";
      repo = "guava";
      rev = "v${guavaVersion}";
      hash = "sha256-OhqOObLNz7bKZXh7usZ9Jlo34BJVEviv/xaQyGhY4Hw=";
    };
    paths = [ "guava" ];
  };
  
  guice = buildJar {
    pname = "guice";
    version = guavaVersion;
    src = fetchFromGitHub {
      owner = "google";
      repo = "guice";
      rev = "${guiceVersion}";
      hash = "sha256-QH8PxfaUWNNu0EvWwRGTuJBpR2j3F9npWGz41wLpHPM=";
    };
  };
  
  sisu-plexus = buildJar {
    pname = "sisu-plexus";
    version = sisuInjectVersion;
    src = fetchFromGitHub {
      owner = "eclipse";
      repo = "sisu.plexus";
      rev = "releases/${sisuInjectVersion}";
      hash = "sha256-RxbGcMkdtGcrKsnP3AyUSFuo5quKdqioHlcPLYqi14c=";
    };
  };
  
  plexus-component-annotations = buildJar {
    pname = "plexus-component-annotations";
    version = plexusVersion;
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-containers";
      rev = "plexus-containers-${plexusVersion}";
      hash = "sha256-rerLwvcYh5MQ+r3WilNy8PkkNkjtTIS94/L8IFkBEdc=";
    };
  };
  
  plexus-classworlds = buildJar {
    pname = "plexus-classworlds";
    version = classWorldsVersion;
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-classworlds";
      rev = "plexus-classworlds-${classWorldsVersion}";
      hash = "sha256-eQSoYbyNZaRqt+YV4QLetZeDHV+33UPJgyLa5UrpaMc=";
    };
  };
  
  plexus-interpolation = buildJar {
    pname = "plexus-interpolation";
    version = plexusInterpolationVersion;
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-interpolation";
      rev = "plexus-interpolation-${plexusInterpolationVersion}";
      hash = "sha256-Ira2mF6XnYc8IlVcRCgprVVgvJbc4LE9xWBC/lgTBB4=";
    };
  };

  slf4j-api = buildJar {
    pname = "slf4j-api";
    version = slf4jVersion;
    src = fetchFromGitHub {
      owner = "qos-ch";
      repo = "slf4j";
      rev = "v_${slf4jVersion}";
      hash = "sha256-ujEcXAlpqRF/GFQOKHRIzVZQTtCyOvuyGCEfGzE6rjU=";
    };
  };

  # OPTIONAL slf4j-simple
  # OPTIONAL logback-classic

  # Wagon
  wagonSource = fetchFromGitHub {
    owner = "apache";
    repo = "maven-wagon";
    rev = "wagon-${wagonVersion}";
    hash = "sha256-G3Fp81qeuh6sRd0ZjKPEP8mqNSK9CFhk/Sx4DX+4Gaw=";
  };
  
  wagon-provider-api = buildJar {
    pname = "wagon-provider-api";
    version = wagonVersion;
    src = wagonSource;
  };
  
  wagon-file = buildJar {
    pname = "wagon-file";
    version = wagonVersion;
    src = wagonSource;
  };
  
  wagon-http = buildJar {
    pname = "wagon-http";
    version = wagonVersion;
    src = wagonSource;
  };

  # Repository

  aetherSource = fetchFromGitHub {
    owner = "sonatype";
    repo = "sonatype-aether";
    rev = "aether-${aetherVersion}";
    hash = "sha256-y4trqsYEZuQ3Qw2tYofSbezestd6vmHgWdObCnEjg/o=";
  };
  
  aether-api = buildJar {
    pname = "aether-api";
    version = aetherVersion;
    src = aetherSource;
  };
  
  aether-spi = buildJar {
    pname = "aether-spi";
    version = aetherVersion;
    src = aetherSource;
  };
  
  aether-impl = buildJar {
    pname = "aether-impl";
    version = aetherVersion;
    src = aetherSource;
  };
  
  aether-util = buildJar {
    pname = "aether-util";
    version = aetherVersion;
    src = aetherSource;
  };
  
  aether-connector-basic = buildJar {
    pname = "aether-connector-basic";
    version = aetherVersion;
    src = aetherSource;
  };
  
  aether-transport-wagon = buildJar {
    pname = "aether-transport-wagon";
    version = aetherVersion;
    src = aetherSource;
  };

  # Commons
  commons-cli = buildJar {
    pname = "commons-cli";
    version = commonsCliVersion;
    src = fetchFromGitHub {
      owner = "apache";
      repo = "commons-cli";
      rev = "cli-${commonsCliVersion}";
      hash = "sha256-vODlZkSWJ7LKAfJaQxzx9ZnD3URj9reezvirS91kOLA=";
    };
  };
  
  commons-jxpath = buildJar {
    pname = "commons-jxpath";
    version = jxpathVersion;
    src = fetchFromGitHub {
      owner = "apache";
      repo = "commons-jxpath";
      rev = "JXPATH_${lib.replaceStrings ["."] ["_"] jxpathVersion}";
      hash = "sha256-cb90IyCBZz3Pi2kRY06R/sxswmUBPObvDlBzCb1Edm8=";
    };
  };
  
  commons-lang3 = buildJar {
    pname = "commons-lang3";
    version = commonsLangVersion;
    src = fetchFromGitHub {
      owner = "apache";
      repo = "commons-lang";
      rev = "LANG_${lib.replaceStrings ["."] ["_"] commonsLangVersion}";
      hash = "sha256-g84NpASyQegCtEMsN1EyTq+KXvVsLGyXbNbjZhgJ/SA=";
    };
  };
  
  plexus-sec-dispatcher = buildJar {
    pname = "plexus-sec-dispatcher";
    version = securityDispatcherVersion;
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-sec-dispatcher";
      rev = "sec-dispatcher-${securityDispatcherVersion}";
      hash = "sha256-D34zNjO/wo2jyNBq+85LrZTCGoKlsPtPf4UveQjdTvU=";
    };
  };
  
  plexus-cipher = buildJar {
    pname = "plexus-cipher";
    version = cipherVersion;
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-cipher";
      rev = "plexus-cipher-${cipherVersion}";
      hash = "sha256-YBm3OY4mn9HpHwBNsD1BZSkjhn63cVYkW7auTr9Fw1Q=";
    };
  };

  };

  #### End Maven 3.3.9 Bootstrap

  plexus-interpolation = stdenvNoCC.mkDerivation rec {
    pname = "plexus-interpolation";
    version = "1.11";
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-interpolation";
      rev = "plexus-interpolation-${version}";
      hash = "sha256-fW3szXVqaFp7WqkG0drRQG+3tsZ3/8xH1tSb2ckZlB4=";
    };
    nativeBuildInputs = [ jdk ];
    buildPhase = ''
      javac -d classes $(find src/main -name '*.java')
    '';
    installPhase = ''
      cd classes; jar cf $out/share/java/${pname}-${version}.jar *
    '';
  };

  plexus-container-default = stdenvNoCC.mkDerivation rec {
    pname = "plexus-container-default";
    version = "1.0-alpha-9-stable-1";
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-containers";
      rev = "plexus-container-default-${version}";
      hash = "";
    };
    nativeBuildInputs = [ jdk ];
    buildPhase = ''
      javac -d classes $(find src/main -name '*.java')
    '';
    installPhase = ''
      cd classes; jar cf $out/share/java/${pname}-${version}.jar *
    '';
  };

  plexus-utils = stdenvNoCC.mkDerivation rec {
    pname = "plexus-utils";
    version = "1.5.15";
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-utils";
      rev = "plexus-utils-${version}";
      hash = "sha256-+EPodNUvV4HpJwG5Boe7t78WEvczUzLdXm8wBTJ2ZEk=";
    };
    nativeBuildInputs = [ jdk plexus-interpolation ];
    buildPhase = ''
      javac -d classes $(find src/main -name '*.java')
    '';
    installPhase = ''
      cd classes; jar cf $out/share/java/${pname}-${version}.jar *
    '';
  };

  # sisu-inject-bean = stdenvnocc.mkDerivation rec {
  #   pname = "sisu-inject-bean";
  #   version = "2.2.0";
  #   src = fetchFromGitHub {
  #     owner = "codehaus-plexus";
  #     repo = "plexus-sec-dispatcher";
  #     rev = "sec-dispatcher-${version}";
  #     hash = "";
  #   };
  #   nativeBuildInputs = [ jdk plexus-utils plexus-cipher plexus-containers ];
  #   buildPhase = ''
  #     javac -d classes $(find src/main -name '*.java')
  #   '';
  #   installPhase = ''
  #     cd classes; jar cf $out/share/java/${pname}-${version}.jar *
  #   '';
  # }

  # This shit is so old... there is no source for it anymore.
  
  # plexus-cipher = stdenvNoCC.mkDerivation rec {
  #   pname = "plexus-cipher";
  #   version = "1.6"; # NOTE: higher than in pom.xml
  #   src = fetchFromGitHub {
  #     owner = "codehaus-plexus";
  #     repo = "plexus-cipher";
  #     rev = "plexus-cipher-${version}";
  #     hash = "";
  #   };
  #   nativeBuildInputs = [ jdk sisu-inject-bean ];
  #   buildPhase = ''
  #     javac -d classes $(find src/main -name '*.java')
  #   '';
  #   installPhase = ''
  #     cd classes; jar cf $out/share/java/${pname}-${version}.jar *
  #   '';
  # };

  # plexus-sec-dispatcher = stdenvNoCC.mkDerivation rec {
  #   pname = "plexus-sec-dispatcher";
  #   version = "1.3";
  #   src = fetchFromGitHub {
  #     owner = "codehaus-plexus";
  #     repo = "plexus-sec-dispatcher";
  #     rev = "sec-dispatcher-${version}";
  #     hash = "";
  #   };
  #   nativeBuildInputs = [ jdk plexus-utils plexus-cipher plexus-containers ];
  #   buildPhase = ''
  #     javac -d classes $(find src/main -name '*.java')
  #   '';
  #   installPhase = ''
  #     cd classes; jar cf $out/share/java/${pname}-${version}.jar *
  #   '';
  # };

  # plexus-build-api = stdenvNoCC.mkDerivation rec {
  #   pname = "plexus-build-api";
  #   version = "1.2.0";
  #   src = fetchFromGitHub {
  #     owner = "codehaus-plexus";
  #     repo = "plexus-build-api";
  #     rev = "plexus-build-api-${version}";
  #     hash = "";
  #   };
  #   nativeBuildInputs = [ jdk ant ];
  #   buildPhase = ''
  #     ant
  #   '';
  # };

  # modello = stdenvNoCC.mkDerivation rec {
  #   pname = "modello";
  #   version = "1.11";
  #   src = fetchFromGitHub {
  #     owner = "codehaus-plexus";
  #     repo = "modello";
  #     rev = "modello-${version}";
  #     hash = "sha256-QqNfJLaZYJPUEKhfQXtPFLGZ/EAgxRQ8HzL9U6MuCKE=";
  #   };
  #   nativeBuildInputs = [ jdk ant ];
  #   buildPhase = ''
  #     ant
  #   '';
  # };

  # Maven 3.3.9 is the last release bootstrappable with ant
  maven_3_3_9 = stdenvNoCC.mkDerivation {
    pname = "maven";
    version = "3.3.9";
    src = fetchFromGitHub {
      owner = "apache";
      repo = "maven";
      rev = "maven-3.3.9";
      hash = "sha256-qqk0FyPo0X43d9Co7qe193D9lIj6DbJ7Tu7WGoD5QkY=";
    };
    nativeBuildInputs = [ jdk ant ];
    buildPhase = ''
      ant -Dmaven.home=$out/maven
    '';
  };

  buildMavenArtifact = args@{pname, version, paths ? ["src/main/java"], group ? "", artifact ? pname, mavenVersion ? version, pom ? "pom.xml", ...}: (buildJar args).overrideAttrs (oa: rec {
    dontBuild = builtins.length paths == 0;
    installPhase = (lib.optionalString (!dontBuild) oa.installPhase) + ''
      group=$(java ${./pomq/Pomq.java} ${pom})
      echo "Found group in ${pom}: $group"
      dir="$out/share/m2/$(echo $group | tr '.' '/')/${artifact}/${mavenVersion}"
      mkdir -p -v $dir
      jar=$out/share/java/${pname}-${version}.jar
      if [ -e $jar ]; then
        ln -s $jar $dir/${artifact}-${version}.jar
      fi
      cp -v ${pom} $dir/${artifact}-${version}.pom
      # Needed? jar --date=1980-01-01T00:00:02Z --update --file $out/share/java/${pname}-${version}.jar ${pom}
      runHook postInstall
    '';
  });

  # Package the plugins, one by one...

  # OK, so in order to build the maven plugins, you first need maven itself (for
  # its libraries).

  in rec {

  # Unpack it from the binary, until it is bootstrapped...
  mavenLibs = pkgs.runCommand "maven-libs" { inherit (pkgs) maven; } ''
    mkdir -p $out/share/java
    find $maven -type f -name '*.jar' -exec cp {} $out/share/java \;
  '';

  apache-pom = buildMavenArtifact rec {
    pname = "apache-pom";
    # TODO extract this from pom, just like groupId is?
    artifact = "apache";
    version = "26";
    src = fetchFromGitHub {
      owner = "apache";
      repo = "maven-apache-parent";
      rev = "apache-${version}";
      hash = "sha256-TL6aNJTfglSM3NZvQ26HYXbaktEKzTU7k3hgF9R+0VI=";
    };
    paths = [ ];
  };

  maven-parent-version = "36";

  maven-parent = fetchFromGitHub {
    owner = "apache";
    repo = "maven-parent";
    rev = "maven-parent-${maven-parent-version}";
    hash = "sha256-g6UYvXXfnufndQUz++KwDjRinRP/nUYoq3L18inWLyg=";
  };

  maven-plugins-pom = buildMavenArtifact {
    pname = "maven-plugins-pom";
    # TODO extract this from pom, just like groupId is?
    artifact = "maven-plugins";
    version = maven-parent-version;
    src = maven-parent;
    paths = [ ];
    pom = "maven-plugins/pom.xml";
  };

  maven-parent-pom = buildMavenArtifact {
    pname = "maven-parent-pom";
    # TODO extract this from pom, just like groupId is?
    artifact = "maven-parent";
    version = maven-parent-version;
    src = maven-parent;
    paths = [ ];
  };

  # 1. Feels like might dissapear at any moment
  # 2. fetchzip falls apart because of two top level dirs
  # Just put it in the repo.
  jsr305 = buildJar rec {
    pname = "jsr305";
    version = "3.0.2";
    src = ./jsr305;
    paths = [ "." ];
  };

  maven-plugin-tools-version = "3.10.2";
  
  maven-plugin-tools = fetchFromGitHub {
    owner = "apache";
    repo = "maven-plugin-tools";
    rev = "maven-plugin-tools-${maven-plugin-tools-version}";
    hash = "sha256-QsYuY+Cs8nHNBvbBYQSU7WMfgtH7MO4WSFrgEgkLmE4=";
  };

  #### Dependencies of maven-plugin-plugin, which is needed to bootstrap
  #### buildMavenArtifact:

  # So need to bootstrap javacc without maven, for velocity engine.
  #
  # Fortunately, they have a build.xml!
  #
  # But wait... javacc is self hosted. How to bootstrap THAT?
  #
  # HACK: For now, just use the non-bootstrapped one that is already in nixpkgs.
  #
  # I wanted to. But velocity is using an ANCIENT version of it. There does NOT
  # appear to be the source code for this anywhere.
  #
  # javacc = pkgs.javacc.overrideAttrs (oa: {
  #   version = "5.0";
  #   doCheck = false;
  #   src = fetchFromGitHub {
  #     owner = "javacc";
  #     repo = "javacc";
  #     rev = "release_60";
  #     hash = "sha256-rCnr+f6RViWvTLghWhCWLm2oODmyZmmMgj20YgunBuU=";
  #   };
  # });
  inherit (pkgs) javacc;
  

  # Velocity engine one uses javacc to generate a parser.
  #
  # Parser definition is in src/main/parser. Also need to emulate maven
  # resources plugin filtering there.
  velocity-engine-core = buildJar rec {
    pname = "velocity-engine-core";
    version = "2.4";
    dependencies = [
      # TODO unwrap from mavenLibs
      # commons-lang3
      # slf4j-api
      mavenLibs
    ];
    src = fetchFromGitHub {
      owner = "apache";
      repo = "velocity-engine";
      rev = version;
      hash = "sha256-+biMZsQHRLRWKd03JsKXgXPKBbj6oDX7Ir3SwJ+Z2Wo=";
    };
    paths = [
      "velocity-engine-core/src/main/java"
      # Looks like most of the generated junk is just that. It causes duplicate
      # class errors. Pick out what is really missing in the source tree:
      "parser/Token.java"
      "parser/StandardParserConstants.java"
      "parser/StandardParser.java"
      "parser/StandardParserTokenManager.java"
      "parser/TokenMgrError.java"
      "parser/StandardParserTreeConstants.java"
      "parser/JJTStandardParserState.java"
    ];
    nativeBuildInputs = [ jdk javacc ];
    # Copied from upstream pom.xml - but looks like it's just old noise - they
    # don't do anything.
    javaccFlags = [
      "STATIC=false"
      "BUILD_PARSER=true"
      "TOKEN_MANAGER_USES_PARSER=true"
      "OUTPUT_DIRECTORY=parser"
    ];
    jjtreeFlags = [
      "BUILD_NODE_FILES=true"
      "MULTI=true"
      "NODE_USES_PARSER=true"
      "NODE_PACKAGE=org.apache.velocity.runtime.parser.node"
      "OUTPUT_DIRECTORY=parser"
    ];
    substitutions = pkgs.writeText "env.properties" ''
      parser.debug=false
      parser.package=org.apache.velocity.runtime.parser
      parser.basename=Standard
      parser.char.asterisk=*
      parser.char.at=@
      parser.char.dollar=$
      parser.char.hash=#
      project.version=2.4
    '';
    configurePhase = ''
      java ${./envsubst/Envsubst.java} \
        ${substitutions} \
        velocity-engine-core/src/main/parser/Parser.jjt \
        parser/Parser.jjt
      # 'template' is a reserved keyword in newer versions or something?
      substituteInPlace parser/Parser.jjt --replace template tmplt
      jjtree ${lib.concatMapStringsSep " " (x: "-${x}") jjtreeFlags} parser/Parser.jjt
      javacc ${lib.concatMapStringsSep " " (x: "-${x}") javaccFlags} parser/Parser.jj
      java ${./envsubst/Envsubst.java} \
        ${substitutions} \
        velocity-engine-core/src/main/java-templates/org/apache/velocity/runtime/VelocityEngineVersion.java \
        velocity-engine-core/src/main/java/org/apache/velocity/runtime/VelocityEngineVersion.java
    '';
    postInstall = ''
      jar --date=1980-01-01T00:00:02Z --update --file $out/share/java/${pname}-${version}.jar -C velocity-engine-core/src/main/resources .
    '';
  };
  
  plexus-velocity = buildJar rec {
    pname = "plexus-velocity";
    version = "2.1.0";
    dependencies = [
      # TODO unwrap from mavenLibs
      # javax-inject
      # sisu-inject
      # slf4j-api # runtime
      mavenLibs

      velocity-engine-core
    ];
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = pname;
      rev = "${pname}-${version}";
      hash = "sha256-bogCl1iIXtZh8WS3zbOP9ZWdXPeNjdxb9enMwIxc+d4=";
    };
  };

  # Need these for maven-plugin-plugin for buildMavenArtifact, for maven plugin
  # descriptor generation. (It seems too complex to try and recreate it by
  # hand.)
  #
  # So need to use the lower-level buildJar. Oops, might mean that need to
  # bootstrap a whole lot of other stuff with buildJar, too

  asm = buildJar rec {
    pname = "asm";
    version = "9.6";
    src = fetchFromGitLab {
      domain = "gitlab.ow2.org";
      owner = "asm";
      repo = "asm";
      rev = "ASM_9_6";
      hash = "sha256-aAAsaGeELcdDs3bmTOn013ZVanOlXaS1ZZ7nng44BP4=";
    };
    paths = [
      "asm/src/main/java"
    ];
  };

  byaccj = stdenv.mkDerivation rec {
    pname = "byaccj";
    version = "1.15";
    src = fetchzip {
      url = "mirror://sourceforge/project/byaccj/byaccj/${version}/byaccj${version}_src.tar.gz";
      hash = "sha256-np+ekTA3F6Vmnj29CN4YijPO74aZsW72Cw4rUOAGRBE=";
    };
    buildPhase = ''
      cc src/*.c -o yacc
    '';
    installPhase = ''
      mkdir -pv $out/bin
      cp yacc $out/bin
    '';
  };

  qdox = buildJar rec {
    pname = "qdox";
    version = "2.1.0";
    src = fetchFromGitHub {
      owner = "paul-hammant";
      repo = "qdox";
      rev = "qdox-${version}";
      hash = "sha256-lCbtAYys/Luuya2fiOQaf3KOYx080UtpZQUvd2EEKfU=";
    };
    paths = [ "src/main/java" "parser" ];
    dependencies = [
      byaccj
      pkgs.jflex # TODO reuse jdk
    ];
    configurePhase = ''
      jflex -d parser/ src/grammar/lexer.flex src/grammar/commentlexer.flex
      (cd parser; yacc -v -Jnorun -Jnoconstruct -Jclass=DefaultJavaCommentParser -Jpackage=com.thoughtworks.qdox.parser.impl ../src/grammar/commentparser.y)
      (cd parser; yacc -v -Jnorun -Jnoconstruct -Jclass=Parser -Jimplements=CommentHandler -Jsemantic=Value -Jpackage=com.thoughtworks.qdox.parser.impl -Jstack=500 ../src/grammar/parser.y)
    '';
  };

  plexus-java = buildJar rec {
    pname = "plexus-java";
    version = "1.2.0";
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-languages";
      rev = "plexus-languages-${version}";
      hash = "sha256-uj8UXISvcixVVPmxE1K4jcNSPCbE2snOk4Mzy1e4zlc=";
    };
    paths = [ "plexus-java/src/main/java" ];
    dependencies = [
      # TODO unpack from mavenLibs
      # javax-inject
      mavenLibs
      asm
      qdox
    ];
  };

  maven-doxia-version = "1.11.1";

  maven-doxia = fetchFromGitHub {
    owner = "apache";
    repo = "maven-doxia";
    rev = "doxia-${maven-doxia-version}";
    hash = "sha256-4edu0TgtTyj6ZH7rO/zoUnZTrFSaJyqr8sFN8ewdSWU=";
  };

  # TODO remove
  # doxia-logging-api = buildJar rec {
  #   pname = "doxia-logging-api";
  #   version = maven-doxia-version;
  #   src = maven-doxia;
  #   dependencies = [ plexus-container-default ];
  #   paths = [ "doxia-logging-api/src/main/java" ];
  # };

  doxia-sink-api = buildJar rec {
    pname = "doxia-sink-api";
    version = maven-doxia-version;
    src = maven-doxia;
    paths = [ "doxia-sink-api/src/main/java" ];
    # Strip out the logging bullcrap
    patches = [ ./patches/org.apache.maven.doxia.sink.Sink.java.patch ];
  };

  maven-reporting-api = buildJar rec {
    pname = "maven-reporting-api";
    version = "3.1.1";
    src = fetchFromGitHub {
      owner = "apache";
      repo = "maven-reporting-api";
      rev = "maven-reporting-api-${version}";
      hash = "sha256-NlIHukl+UTDdXVE2cRQOedodggnckSdVlUpfmDaz/jY=";
    };
    dependencies = [
      doxia-sink-api
    ];
  };
  
  maven-plugin-tools-api = buildJar rec {
    pname = "maven-plugin-tools-api";
    version = maven-plugin-tools-version;
    src = maven-plugin-tools;
    dependencies = [
      # TODO unwrap from mavenLibs
      # maven-core
      # maven-model
      # maven-plugin-api
      # maven-artifact
      # slf4j-api
      # plexus-utils
      # wagon-provider-api
      mavenLibs

      maven-reporting-api
      
      # Declared, but code compiles without them.
      # plexus-java
      # plexus-xml
    ];
    paths = [ "maven-plugin-tools-api/src/main/java" ];
    postPatch = ''
      # Not going to be making any http requests
      rm maven-plugin-tools-api/src/main/java/org/apache/maven/tools/plugin/javadoc/JavadocSite.java
      rm maven-plugin-tools-api/src/main/java/org/apache/maven/tools/plugin/javadoc/JavadocLinkGenerator.java
    '';
  };

  plexus-io = buildJar rec {
    pname = "plexus-io";
    version = "3.4.1";
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-io";
      rev = "plexus-io-${version}";
      hash = "sha256-YqVQJn2xttDM3khktS3SdwI4UANtV5CHxJ4nw4w1P6I=";
    };
    dependencies = [
      # TODO unwrap from mavenLibs
      # plexus-utils
      # commons-io
      mavenLibs
      
      jsr305
    ];
  };

  bitshuffle = stdenv.mkDerivation rec {
    pname = "bitshuffle";
    version = "0.5.1";
    src = fetchFromGitHub {
      owner = "kiyo-masui";
      repo = "bitshuffle";
      rev = version;
      hash = "sha256-wZvCi9pKWEOVlT69IUY2cjyiia1m0bLPXh7JqJmRtIs=";
    };
    nativeBuildInputs = [
      pkgs.lz4 pkgs.hdf5
    ];
    patchPhase = ''
      rm src/lzf_h5plugin.c
    '';
    buildPhase = ''
      cc src/*.c -shared -o libbitshuffle.so
    '';
    installPhase = ''
      mkdir -pv $out/{lib,include}
      cp libbitshuffle.so $out/lib
      patchelf --add-needed ${pkgs.lz4.out}/lib/liblz4.so $out/lib/libbitshuffle.so
      cp src/{bitshuffle,bitshuffle_core}.h $out/include
    '';
  };

  snappy = stdenv.mkDerivation rec {
    pname = "snappy-java";
    version = "1.1.8";
    src = fetchFromGitHub {
      owner = "xerial";
      repo = "snappy-java";
      rev = version;
      hash = "sha256-lsJ2zBJWQO5T7Z9ug5Bsp84zl9yNmbhFTASfGJPvd9w=";
    };
    nativeBuildInputs = [ pkgs.snappy pkgs.jdk bitshuffle ];
    patchPhase = ''
      find . -type f \( -not -name '*.java' \) -and \( -not -name '*.cpp' \) -and \( -not -name '*.h' \) -exec rm -v {} \;
      rm -rvf lib # Remove vendored headers
      rm src/main/java/org/xerial/snappy/SnappyBundleActivator.java
    '';
    buildPhase = ''
      mkdir build classes
      for x in $(find src -name '*.cpp'); do
      c++ -Isrc/main/java/org/xerial/snappy $(find src/main/java -name '*.cpp') -shared -o libsnappyjava.so
      done
      javac $(find src/main/java -name '*.java') -d classes
    '';
    installPhase = ''
      mkdir -pv $out/share/java $out/lib
      cp libsnappyjava.so $out/lib
      patchelf --add-needed ${bitshuffle}/lib/libbitshuffle.so $out/lib/libsnappyjava.so
      patchelf --add-needed ${pkgs.snappy}/lib/libsnappy.so $out/lib/libsnappyjava.so
      jar -cf $out/share/java/${pname}-${version}.jar -C classes .
      echo 'org.xerial.snappy.use.systemlib=true' > org-xerial-snappy.properties
      jar -uf $out/share/java/${pname}-${version}.jar org-xerial-snappy.properties
    '';
  };

  plexus-archiver = buildJar rec {
    pname = "plexus-archiver";
    version = "4.9.1";
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-archiver";
      rev = "plexus-archiver-${version}";
      hash = "sha256-iqI7NWzZ7p9fXCWkyYMX/CoMZVoiTNJUjqnRmhojJi4=";
    };
    dependencies = [
      # TODO unwrap from mavenLibs
      # javax-inject
      # plexus-utils
      # commons-io
      # slf4j-api
      mavenLibs

      plexus-io
      snappy
      # commons-compress
      # xz
      # zstd-jni
      # jsr305
    ];
  };

  maven-plugin-tools-annotations = buildJar rec {
    pname = "maven-plugin-tools-annotations";
    version = maven-plugin-tools-version;
    src = maven-plugin-tools;
    paths = [ "maven-plugin-tools-annotations/src/main/java" ];
    dependencies = [
      # TODO unwrap from mavenLibs
      # maven-plugin-api
      # maven-core
      # maven-model
      # maven-artifact
      # slf4j-api
      # plexus-utils
      # sisu-plexus
      mavenLibs
      
      plexus-archiver
      # asm
      # asm-util
      # jsoup
      # qdox
      # maven-plugin-tools-api
      # maven-plugin-annotations
    ];
  };
  
  maven-plugin-plugin = buildJar rec {
    pname = "maven-plugin-plugin";
    version = maven-plugin-tools-version;
    src = maven-plugin-tools;
    dependencies = [
      # TODO unwrap from mavenLibs
      # maven-core
      # maven-plugin-api
      # maven-model
      # maven-repository-metadata
      # maven-artifact
      # plexus-utils
      # plexus
      mavenLibs
      
      plexus-velocity
      
      # For m2e support, maybe can be stripped out
      # plexus-build-api
      
      maven-plugin-tools-api
      # maven-plugin-tools-generators
      # maven-plugin-tools-java
      # maven-plugin-tools-annotations
      
      # Maybe don't need this. I will call the lib not the mojo.
      # maven-plugin-annotations
    ];
    paths = [ "maven-plugin-plugin/src/main/java" ];
  };
    
  maven-plugin-annotations = buildJar rec {
    pname = "maven-plugin-annotations";
    version = maven-plugin-tools-version;
    src = maven-plugin-tools;
    paths = [ "maven-plugin-annotations/src/main/java" ];
    # pom = "maven-plugin-annotations/pom.xml";
  };

  plexus-xml = buildJar rec {
    pname = "plexus-xml";
    version = "3.0.0";
    dependencies = [
    ];
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-xml";
      rev = "plexus-xml-${version}";
      hash = "sha256-swOntzNJYniHdoJi1fO83L2tpqwfHshpqd955mBWAJI=";
    };
  };

  classworlds = buildMavenArtifact rec {
    pname = "classworlds";
    version = "1.2-alpha-3";
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-classworlds";
      rev = "plexus-classworlds-${classWorldsVersion}";
      hash = "sha256-eQSoYbyNZaRqt+YV4QLetZeDHV+33UPJgyLa5UrpaMc=";
    };
  };

  # WOW! THIS IS OLD!
  plexus-container-default = buildMavenArtifact rec {
    pname = "plexus-container-default";
    version = "1.0-alpha-9-stable-1@6237";
    dependencies = [
      # TODO unwrap from mavenLibs
      # plexus-utils
      mavenLibs

      # junit # Really?
      classworlds
    ];
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-containers";
      rev = "plexus-container-default-${version}";
      hash = "sha256-xOxueiVl3d1Eeq5xJzziOkDAxoglo3IwI7CxDKNzdcI=";
    };
    patches = [
      ./patches/org.codehaus.plexus.embed.Embedder.java.patch
    ];
    postPatch = ''
     rm -v src/main/java/org/codehaus/plexus/PlexusTestCase.java
    '';
  };

  plexus-build-api = buildMavenArtifact rec {
    pname = "plexus-build-api";
    version = "0.0.7";
    dependencies = [
      # TODO unwrap from mavenLibs
      # plexus-utils
      mavenLibs
      
      plexus-container-default
    ];
    patches = [
      ./patches/org.sonatype.plexus.build.incremental.EmptyScanner.java.patch 
    ];
    src = fetchFromGitHub {
      owner = "sonatype";
      repo = "sisu-build-api";
      rev = "plexus-build-api-${version}";
      hash = "sha256-QDHojfMpSKhfhfEhgszxFDCYe9gcnx1KA6PPhwozvLQ=";
    };
  };

  maven-filtering = buildMavenArtifact rec {
    pname = "maven-filtering";
    version = "3.3.1";
    dependencies = [
      # TODO unwrap from mavenLibs
      # javax-inject
      # slf4j-api
      # maven-core
      # maven-model
      # maven-settings
      # plexus-utils
      # plexus-interpolation
      # commons-io
      # commons-lang3
      mavenLibs
      
      plexus-xml
      plexus-build-api
    ];
    src = fetchFromGitHub {
      owner = "apache";
      repo = "maven-filtering";
      rev = "maven-filtering-${version}";
      hash = "sha256-Wfi8g+a5e55UVyJjsRggUiK0NPNcE+UEWPcS1dMtZWM=";
    };
  };
  
  maven-resources-plugin = buildMavenArtifact rec {
    group = "org.apache.maven.plugins";
    pname = "maven-resources-plugin";
    version = "3.3.0";
    dependencies = [
      # TODO unwrap from mavenLibs
      # maven-plugin-api
      # maven-core
      # maven-model
      # maven-settings
      # plexus-utils
      # plexus-interpolation
      # commons-io
      # commons-lang3
      # plexus
      mavenLibs
      
      maven-plugin-annotations
      maven-filtering
    ];
    src = fetchFromGitHub {
      owner = "apache";
      repo = "maven-resources-plugin";
      rev = "maven-resources-plugin-${version}";
      hash = "sha256-ld8uURjbVRCxAJcllD8B4yj4Lzd5ANQIbEvbprIM1Fw=";
    };
  };

  buildM2 = artifacts: stdenvNoCC.mkDerivation {
    pname = "m2";
    version = "repository";
    buildInputs = artifacts;
    dontUnpack = true;
    installPhase = ''
      declare -A seen=()
      mkdir -pv $out/share/m2
      addPathToM2 () {
        if [ -v seen[$1] ]; then
          return
        fi
        seen[$1]=1
        for group0 in $1/share/m2/*; do
          echo "Doing top level group: $group0"
          ls -l $out/share/m2
          chmod -R a+w $out/share/m2
          cp -rs $group0 $out/share/m2
          prop=$1/nix-support/propagated-build-inputs
          if [ -e $prop ]; then
            for next in $(cat $prop); do
              addPathToM2 $next
            done
          fi
        done
      }
      for path in $(echo $buildInputs); do
        echo "Doing build input: $path"
        addPathToM2 $path
      done
      # exit 42 # Debug
    '';
  };

  buildMavenProject = {
    pname
    , version
    , src
    , m2 ? []
    , doCheck ? false
    , goal ? "package"
    , testGoal ? "test"
    , installGoal ? "install"
    , jdk ? pkgs.jdk
    , maven ? pkgs.maven.override { inherit jdk; } # Needed ?
  }: stdenvNoCC.mkDerivation {
    
    inherit pname version src doCheck;

    nativeBuildInputs = [ jdk maven ];

    M2 = buildM2 m2;

    configurePhase = ''
      echo "Maven repo is: $M2"
    '';

    # Fails due to missing plugins/mojos
    # Do they come with maven when bootstrapped? (Nixpkgs has a binary version)
    # Or are they in separate projects?
    buildPhase = ''
      # mvn -e --offline -Dmaven.repo.local=$M2/share/m2 ${goal} -DskipTests=true;
      mvn --offline -Dmaven.repo.local=$M2/share/m2 ${goal} -DskipTests=true;
    '';

    checkPhase = ''
      mvn -o ${testGoal}
    '';

    installPhase = ''
      mvn -o ${installGoal}
    '';
    
  };
  


  # inherit mavenDeps;

  allMavenDeps = pkgs.buildEnv { name = "jars"; paths = builtins.attrValues mavenDeps; };

  # inherit plexus-interpolation plexus-utils modello maven_3_3_9;

  # inherit mavenLibs;
  # inherit maven-resources-plugin;

  jfreechart = buildMavenProject {
    pname = "jfreechart";
    version = "1.5.4";
    m2 = [
      # FIXME figure out where it really belongs
      # TODO multiple jars/poms per derivation
      maven-plugins-pom
      maven-parent-pom
      apache-pom
      
      maven-resources-plugin
    ];
    src = fetchFromGitHub {
      owner = "jfree";
      repo = "jfreechart";
      rev = "v1.5.4";
      hash = "sha256-+6CE14zCDvlmaNNDxitoTkys5l6q16ztrxD6gJtOtV4=";
    };    
  };

  jsoup = buildMavenProject {
    pname = "jsoup";
    version = "1.17.2";
    src = fetchFromGitHub {
      owner = "jhy";
      repo = "jsoup";
      rev = "jsoup-1.17.2";
      hash = "sha256-Zkq2W9p8AAgeuWxze1QJfmmzwLPz4iNm6UggW5sZmJ0=";
    };    
  };
  
}
    
