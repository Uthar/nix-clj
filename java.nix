{ stdenvNoCC, lib, pkgs, fetchFromGitHub, fetchzip, jdk, ant, ... }:

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

  buildJar = {
    pname, version, src
    , dependencies ? []
    , paths ? ["src/main/java"]
    , ...
  }: stdenvNoCC.mkDerivation {
    inherit pname version src;
    nativeBuildInputs = [ jdk ] ++ dependencies;
    buildPhase = ''
      javac -encoding utf-8 -d classes $(find ${lib.concatStringsSep " " paths} -type f -name '*.java')
    '';
    installPhase = ''
      mkdir -p $out/share/java
      jar --date=1980-01-01T00:00:02Z --create --file $out/share/java/${pname}-${version}.jar -C classes .
    '';
  };

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

  buildMavenArtifact = args@{pname, version, pom ? "pom.xml", ...}: (buildJar args).overrideAttrs (oa: {
    installPhase = oa.installPhase + ''
      jar --date=1980-01-01T00:00:02Z --update --file $out/share/java/${pname}-${version}.jar ${pom}
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

  maven-plugin-tools-version = "3.11.0";

  maven-plugin-tools = fetchFromGitHub {
    owner = "apache";
    repo = "maven-plugin-tools";
    rev = "maven-plugin-tools-${maven-plugin-tools-version}";
    hash = "sha256-PHjFByRUkHLPIKc1kPOb2s2x5VXHcQ+4sT8YP55y6WQ=";
  };
  
  maven-plugin-annotations = buildMavenArtifact rec {
    pname = "maven-plugin-annotations";
    version = maven-plugin-tools-version;
    src = maven-plugin-tools;
    paths = [ "maven-plugin-annotations/src/main/java" ];
    pom = "maven-plugin-annotations/pom.xml";
  };

  maven-filtering = buildMavenArtifact rec {
    pname = "maven-filtering";
    version = "3.3.1";
    dependencies = [ mavenLibs ];
    src = fetchFromGitHub {
      owner = "apache";
      repo = "maven-filtering";
      rev = "maven-filtering-${version}";
      hash = "sha256-Wfi8g+a5e55UVyJjsRggUiK0NPNcE+UEWPcS1dMtZWM=";
    };
  };

  plexus-build-api = buildMavenArtifact rec {
    pname = "plexus-build-api";
    version = "0.0.7";
    dependencies = [ mavenLibs ]; # This will bite back when I bootstrap...
    src = fetchFromGitHub {
      owner = "sonatype";
      repo = "sisu-build-api";
      rev = "plexus-build-api-${version}";
      hash = "sha256-QDHojfMpSKhfhfEhgszxFDCYe9gcnx1KA6PPhwozvLQ=";
    };
  };
  
  maven-resources-plugin = buildMavenArtifact rec { 
    pname = "maven-resources-plugin";
    version = "3.3.0";
    dependencies = [ mavenLibs maven-plugin-annotations ];
    src = fetchFromGitHub {
      owner = "apache";
      repo = "maven-resources-plugin";
      rev = "maven-resources-plugin-${version}";
      hash = "sha256-ld8uURjbVRCxAJcllD8B4yj4Lzd5ANQIbEvbprIM1Fw=";
    };
  };

  buildMavenProject = {
    pname
    , version
    , src
    , doCheck ? false
    , goal ? "package"
    , testGoal ? "test"
    , installGoal ? "install"
    , jdk ? pkgs.jdk
    , maven ? pkgs.maven.override { inherit jdk; } # Needed ?
  }: stdenvNoCC.mkDerivation {
    
    inherit pname version src doCheck;

    nativeBuildInputs = [ jdk maven ];

    configurePhase = ''
      export MAVEN_REPOSITORY=$(pwd)/m2
      mkdir -p $MAVEN_REPOSITORY/org/apache/maven/plugins/maven-resources-plugin/3.3.0
      touch $MAVEN_REPOSITORY/org/apache/maven/plugins/maven-resources-plugin/3.3.0/maven-resources-plugin-3.3.0.jar
      touch $MAVEN_REPOSITORY/org/apache/maven/plugins/maven-resources-plugin/3.3.0/maven-resources-plugin-3.3.0.pom
    '';

    # Fails due to missing plugins/mojos
    # Do they come with maven when bootstrapped? (Nix has a binary version)
    # Or are they in separate projects?
    buildPhase = ''
      mvn --offline -Dmaven.repo.local=$MAVEN_REPOSITORY ${goal} -DskipTests=true;
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
    
