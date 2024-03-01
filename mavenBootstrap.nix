{ pkgs, stdenvNoCC, lib, fetchurl, fetchFromGitLab, fetchFromGitHub, ... }:

# Bootstrapping Maven from source.
#
# The result is a mvn executable which can build pom.xml projects.
#
# Could bootstrap an older version, but the code for such old dependencies is
# hard to find. Might as well do a newer one.

rec {

  ## Config
  jdk = pkgs.jdk11;

  
  ## Machinery
  buildJar = args@{
    pname, version, src
    , dependencies ? []
    , findCommands ? []
    , paths ? ["src/main/java"]
    , javacFlags ? ["-encoding utf-8"]
    , ...
  }: stdenvNoCC.mkDerivation ({
    inherit pname version src;
    nativeBuildInputs = [ jdk ] ++ dependencies;
    propagatedBuildInputs = dependencies;
    buildPhase = ''
      runHook preBuild
      mkdir classes
      ${lib.optionalString (builtins.length paths > 0)
        "find ${lib.concatStringsSep " " paths} -type f -name '*.java' >> sources.txt"}
      ${lib.concatMapStringsSep "\n" (x: "${x} >> sources.txt") findCommands}
      javac ${lib.concatStringsSep " " javacFlags} -d classes @sources.txt
    '';
    installPhase = ''
      mkdir -p $out/share/java
      jar cf $out/share/java/${pname}-${version}.jar -C classes .
      runHook postInstall
    '';
  } // args);

  
  ## Maven itself
  mavenVersion = "3.9.6";

  mavenSrc = fetchFromGitHub {
    owner = "apache";
    repo = "maven";
    rev = "maven-${mavenVersion}";
    hash = "sha256-BKy8AEZ5uZJyaBe+begHf0iZgVEgopGXgsdFn0WGDnc=";
  };

  mavenModule = { pname, dependencies ? [] }: buildJar {
    inherit pname dependencies;
    src = mavenSrc;
    version = mavenVersion;
    paths = [ "${pname}/src/main/java" ];
  };

  maven = {};

  maven-core = mavenModule {
    pname = "maven-core";
    dependencies = [
      maven-model
      maven-settings
      maven-settings-builder
      maven-builder-support
      maven-repository-metadata
      maven-artifact
      maven-plugin-api
      maven-model-builder
      maven-resolver-provider
      maven-resolver-impl
      maven-resolver-api
      maven-resolver-spi
      maven-resolver-util
      maven-shared-utils
      sisu-plexus
      sisu-inject
      guice
      guava # bundles failureaccess
      javax-inject
      plexus-utils
      plexus-classworlds
      plexus-interpolation
      plexus-component-annotations
      commons-lang3
      slf4j-api
    ];
  };

  maven-model = mavenModule {
    pname = "maven-model";
    dependencies = [
      plexus-utils
    ];
  };

  maven-settings = mavenModule {
    pname = "maven-settings";
    dependencies = [
      plexus-utils
    ];
  };

  maven-settings-builder = mavenModule {
    pname = "maven-settings-builder";
    dependencies = [
      maven-builder-support
      javax-inject
      plexus-interpolation
      plexus-utils
      maven-settings
      plexus-sec-dispatcher
    ];
  };

  maven-builder-support = mavenModule {
    pname = "maven-builder-support";
  };

  maven-repository-metadata = mavenModule {
    pname = "maven-repository-metadata";
    dependencies = [
      plexus-utils
    ];
  };

  maven-artifact = mavenModule {
    pname = "maven-artifact";
    dependencies = [
      plexus-utils
      commons-lang3
    ];
  };

  maven-plugin-api = mavenModule {
    pname = "maven-plugin-api";
    dependencies = [
      maven-model
      maven-artifact
      wagon-provider-api
      sisu-plexus
      plexus-utils
      plexus-classworlds
    ];
  };

  maven-model-builder = mavenModule {
    pname = "maven-model-builder";
    dependencies = [
      plexus-utils
      plexus-interpolation
      javax-inject
      maven-model
      maven-artifact
      maven-builder-support
      sisu-inject
    ];
  };

  maven-resolver-provider = mavenModule {
    pname = "maven-resolver-provider";
    dependencies = [
      maven-model
      maven-model-builder
      maven-repository-metadata
      maven-resolver-api
      maven-resolver-spi
      maven-resolver-util
      maven-resolver-impl
      plexus-utils
      javax-inject
    ];
  };

  
  ## Maven artifact resolver
  maven-resolver-impl = {};
  maven-resolver-api = {};
  maven-resolver-spi = {};
  maven-resolver-util = {};
  

  ## Sisu
  sisu-plexus = buildJar rec {
    pname = "sisu-plexus";
    version = "0.9.0.M2";
    src = fetchFromGitHub {
      owner = "eclipse";
      repo = "sisu.plexus";
      rev = "milestones/${version}";
      hash = "sha256-NMxRJpEd79Kbzkdj4puNbX6srAzry8Pny9PH8I/SEv0=";
    };
    paths = [ "org.eclipse.sisu.plexus/src/main/java" ];
    dependencies = [
      guice
      javax-annotation-api
      # cdi-api
      sisu-inject
      plexus-component-annotations
      plexus-classworlds
      plexus-utils
    ];
  };
  
  sisu-inject = buildJar rec {
    pname = "sisu-inject";
    version = "0.9.0.M2";
    src = fetchFromGitHub {
      owner = "eclipse";
      repo = "sisu.inject";
      rev = "milestones/${version}";
      hash = "sha256-L6nCmXi6Lt8oqVwYT7730hCcQuoJvTm/cdyBUin/Egs=";
    };
    paths = [ "org.eclipse.sisu.inject/src/main/java" ];
    dependencies = [
      guice
      guice-servlet
      slf4j-api
    ];
  };

  
  ## Plexus
  plexus-utils = buildJar rec {
    pname = "plexus-utils";
    version = "3.5.1";
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-utils";
      rev = "plexus-utils-${version}";
      hash = "sha256-GFfdZqQKt0EG6C1CmOKa8CAZd2fxo3PkxHI259TWoH4=";
    };
  };
  
  plexus-classworlds = buildJar rec {
    pname = "plexus-classworlds";
    version = "2.7.0";
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-classworlds";
      rev = "plexus-classworlds-${version}";
      hash = "sha256-caEWQv4XYkI+S7Zo7BgWqZL+lhkg9AzIP9thjOwEkrg=";
    };
  };
  
  plexus-interpolation = buildJar rec {
    pname = "plexus-interpolation";
    version = "1.26";
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-interpolation";
      rev = "plexus-interpolation-${version}";
      hash = "sha256-kP7uahc6j+AGmKm6pcJpbHuufkyMfixGLc047mGVUOU=";
    };
  };
  
  plexus-component-annotations = buildJar rec {
    pname = "plexus-component-annotations";
    version = "2.1.0";
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-containers";
      rev = "plexus-containers-${version}";
      hash = "sha256-weboTjlNqQmLHFT5o9DdqroyoemmV17+DXHDwI7BPmU=";
    };
    paths = [ "plexus-component-annotations/src/main/java" ];
  };
  
  plexus-sec-dispatcher = buildJar rec {
    pname = "plexus-sec-dispatcher";
    version = "2.0";
    src = fetchFromGitHub {
      owner = "codehaus-plexus";
      repo = "plexus-sec-dispatcher";
      rev = "plexus-sec-dispatcher-${version}";
      hash = "sha256-85qZQ/sVE6OTbiI4lWTqLfj9ibFN7Nebt1Ps2T37xRg=";
    };
  };

  
  ## Commons
  commons-lang3 = buildJar rec {
    pname = "commons-lang3";
    version = "3.12.0";
    src = fetchFromGitHub {
      owner = "apache";
      repo = "commons-lang";
      rev = "rel/commons-lang-${version}";
      hash = "sha256-rMwGIeRxvUKHCbWOvT/KA8KbxA6nZcD+FeCQrYlben8=";
    };
  };

  
  ## Guava
  guava = buildJar rec {
    pname = "guava";
    version = "32.0.1";
    src = fetchFromGitHub {
      owner = "google";
      repo = "guava";
      rev = "v${version}";
      hash = "sha256-onXXXmrQfPrx53g4qoXOpkV43XO9Bv3hfJXHsB1njpA=";
    };
    paths = [ "guava/src" "futures/failureaccess/src" ];
    dependencies = [
      jsr305
      checker-qual
      error_prone_annotations
      j2objc-annotations
    ];
  };

  jspecify = buildJar rec {
    pname = "jspecify";
    version = "0.3.0";
    src = fetchFromGitHub {
      owner = "jspecify";
      repo = "jspecify";
      rev = "v${version}";
      hash = "sha256-kPeRTncvY5iIQQ4AOM6prOFxMRjvM8Dc8/wPuJFk5go=";
    };
  };

  args4j = buildJar rec {
    pname = "args4j";
    version = "2.0.16";
    src = fetchFromGitHub {
      owner = "kohsuke";
      repo = "args4j";
      rev = "args4j-${version}";
      hash = "sha256-rkeqG2xsBMpXe5Y4kExOg2undoFs1HqmU+ehQoQltPo=";
    };
    postPatch = ''
      substituteInPlace $(grep --files-with-matches -r 'IllegalAccessException _') \
        --replace 'IllegalAccessException _' 'IllegalAccessException __'
    '';
    paths = [
      "args4j/src"
    ];
  };

  protobuf-java = buildJar rec {
    pname = "protobuf-java";
    version = pkgs.protobuf.version;
    src = pkgs.protobuf.src;
    paths = [ "java/core/src/main/java" ];
    preBuild = ''
      protoc --java_out=java/core/src/main/java \
        -Isrc src/google/protobuf/descriptor.proto
    '';
    dependencies = [ pkgs.protobuf ];
  };

  gson = buildJar rec {
    pname = "gson";
    version = "2.4";
    src = fetchFromGitHub {
      owner = "google";
      repo = "gson";
      rev = "gson-${version}";
      hash = "sha256-Z3uMZTW7jTwXiV3V5TLs6q2HVSU5trvLm/4mniWQJYo=";
    };
    paths = [ "gson/src/main/java" ];
  };

  javapoet = buildJar rec {
    pname = "javapoet";
    version = "1.13.0";
    src = fetchFromGitHub {
      owner = "square";
      repo = "javapoet";
      rev = "javapoet-${version}";
      hash = "sha256-Pj28ZTJFi9WB5Qnl8XIrSkRkzdA4De0o4vL9Ww9XjuA=";
    };
  };

  auto-common = buildJar rec {
    pname = "auto-common";
    version = "1.10.4";
    src = fetchFromGitHub {
      owner = "google";
      repo = "auto";
      rev = "auto-value-${version}";
      hash = "sha256-AlgvL6wGtxt/1CiNEhjpaGK29MaBuSEubkvgUexYtCA=";
    };
    paths = [      
      "common/src/main/java"
    ];
    dependencies = [
      guava
      javapoet
    ];
  };

  auto-service-annotations = buildJar rec {
    pname = "auto-service-annotations";
    version = "1.10.4";
    src = fetchFromGitHub {
      owner = "google";
      repo = "auto";
      rev = "auto-value-${version}";
      hash = "sha256-AlgvL6wGtxt/1CiNEhjpaGK29MaBuSEubkvgUexYtCA=";
    };
    paths = [
      "service/annotations/src/main/java"
    ];
    dependencies = [
    ];
  };

  auto-service-processor = buildJar rec {
    pname = "auto-service-processor";
    version = "1.10.4";
    src = fetchFromGitHub {
      owner = "google";
      repo = "auto";
      rev = "auto-value-${version}";
      hash = "sha256-AlgvL6wGtxt/1CiNEhjpaGK29MaBuSEubkvgUexYtCA=";
    };
    paths = [
      "service/processor/src/main/java"
    ];
    dependencies = [
      auto-service-annotations
      auto-common
      guava
    ];
  };

  escapevelocity = buildJar rec {
    pname = "escapevelocity";
    version = "1.1";
    src = fetchFromGitHub {
      owner = "google";
      repo = "escapevelocity";
      rev = "escapevelocity-${version}";
      hash = "sha256-SaDNmUDlsK9v1ojJIuL6rENizRcqJaM7CpiZZi3kb+s=";
    };
    dependencies = [
      guava
    ];
  };

  incap = buildJar rec {
    pname = "incap";
    version = "1.0.0";
    src = fetchFromGitHub {
      owner = "tbroyer";
      repo = "gradle-incap-helper";
      rev = "v${version}";
      hash = "sha256-RgMiLTeGL5bZBADuWyQmur7oRghzmb/bbo2+wAVda54=";
    };
    paths = [
      "lib/src/main/java"
      "processor/src/main/java"
    ];
    dependencies = [
      auto-service-annotations
    ];
  };

  kotlin-stdlib = buildJar rec {
    pname = "kotlin-stdlib";
    version = "1.9.22";
    src = fetchFromGitHub {
      owner = "JetBrains";
      repo = "kotlin";
      sparseCheckout = [
        "libraries/stdlib"
      ];
      rev = "v1.9.22";
      hash = "sha256-Bnc6IhiLgknZCNB6xYYfDorVsIuyu6QqlhIVg84McpU=";
    };
    paths = [
      "libraries/stdlib/common/src/kotlin"
    ];
  };

  kotlinx-metadata-jvm = buildJar rec {
    pname = "kotlinx-metadata-jvm";
    version = "0.7.0";
    src = fetchFromGitHub {
      owner = "JetBrains";
      repo = "kotlin";
      sparseCheckout = [
        "libraries/stdlib"
      ];
      rev = "v1.9.22";
      hash = "sha256-U5ItB9vaylpiyWf8N3gS8s/TG18ciS2m4QSW2kAibDg=";
    };
    paths = [ "libraries/kotlinx-metadata/jvm/src" ];
  };

  auto-value = buildJar rec {
    pname = "auto-value";
    version = "1.10.4";
    src = fetchFromGitHub {
      owner = "google";
      repo = "auto";
      rev = "auto-value-${version}";
      hash = "sha256-AlgvL6wGtxt/1CiNEhjpaGK29MaBuSEubkvgUexYtCA=";
    };
    paths = [
      "value/src/main/java"
    ];
    dependencies = [
      auto-common
      auto-service-annotations
      error_prone_annotations
      escapevelocity
      incap
      guava
      # kotlinx-metadata-jvm
      javapoet
      asm
    ];
  };

  closure-compiler = buildJar rec {
    pname = "closure-compiler";
    version = "v20231112";
    src = fetchFromGitHub {
      owner = "google";
      repo = "closure-compiler";
      rev = version;
      hash = "sha256-Js006eVd4KngVu1XdyLbOBmQm5bWe/jJgsl+SsOS+KA=";
    };
    # Uses an older version of jspecify.
    postPatch = ''
      substituteInPlace $(grep -l -r org.jspecify.nullness.Nullable) \
        --replace org.jspecify.nullness org.jspecify.annotations
    '';
    paths = [];
    # Seems like it also needs some ConformanceConfig thing
    # It may be a source file generated by protobuf
    preBuild = ''
      protoc --java_out=src src/com/google/debugging/sourcemap/proto/mapping.proto
      protoc --java_out=src src/com/google/javascript/jscomp/conformance/conformance.proto
      protoc --java_out=src src/com/google/javascript/jscomp/instrumentation/reporter/proto/profile.proto
      protoc --java_out=src src/com/google/javascript/rhino/typed_ast/*.proto
    '';
    findCommands = [
      "find -path './src/com/google/**/*.java' \ -and -not -path '**/debugger/**/*.java' \ -and -not -path '**/j2clbuild/**/*.java' \ -and -not -path '**/j2cl/**/*.java' \ -and -not -path '**/super*/**/*.java' \ -and -not -path '**/testing/**/*.java'  \ -and -not -path '**/webservice/**/*.java'"
    ];
    dependencies = [
      pkgs.protobuf
      protobuf-java
      args4j
      gson
      error_prone_annotations
      guava
      # re2j
      # ant
      jspecify
    ];
  };


  
  guice = buildJar rec {
    pname = "guice";
    version = "5.1.0";
    src = fetchFromGitHub {
      owner = "google";
      repo = "guice";
      rev = "${version}";
      hash = "sha256-4WwZXJnQ6gy/biGChzffhDjoY/ZdMOPMGsIgWWl6iBc=";
    };
    paths = [ "core/src" ];
    dependencies = [
      javax-inject
      aopalliance
      asm
      guava
    ];
  };

  guice-servlet = buildJar rec {
    pname = "guice-servler";
    version = "5.1.0";
    src = fetchFromGitHub {
      owner = "google";
      repo = "guice";
      rev = "${version}";
      hash = "sha256-4WwZXJnQ6gy/biGChzffhDjoY/ZdMOPMGsIgWWl6iBc=";
    };
    paths = [ "extensions/servlet/src" ];
    dependencies = [
      guice
      javax-servlet-api
    ];
  };

  # Misc dependencies

  jsr305 = buildJar rec {
    pname = "jsr305";
    version = "3.0.2";
    src = fetchurl {
      url = "mirror://maven/com/google/code/findbugs/jsr305/${version}/jsr305-${version}-sources.jar";
      hash = "sha256-HJ6F4nLQcIxqWR3HSCjHFgMFO0jMda6DzOVpEqKqBjs=";
    };
    unpackPhase = ''
      jar xf $src
    '';
    paths = [ "." ];
  };

  checker-qual = buildJar rec {
    pname = "checker-qual";
    version = "3.33.0";
    src = fetchFromGitHub {
      owner = "typetools";
      repo = "checker-framework";
      rev = "checker-framework-${version}";
      hash = "sha256-4Ud7UL5Zo2lsXT8ke8VEKswupIcrXGFcd5I+LI1EfFM=";
    };
    paths = [ "checker-qual/src/main/java" ];
  };

  error_prone_annotations = buildJar rec {
    pname ="error_prone_annotations";
    version = "2.18.0";
    src = fetchFromGitHub {
      owner = "google";
      repo = "error-prone";
      rev = "v${version}";
      hash = "sha256-LowEruqXNyKEASzZvO0ZWOLVvgLBuZGbghmBscDXWKc=";
    };
    paths = [ "annotations/src/main/java" ];
  };

  j2objc-annotations = buildJar rec {
    pname ="j2objc-annotations2";
    version = "2.8";
    src = fetchFromGitHub {
      owner = "google";
      repo = "j2objc";
      rev = "${version}";
      hash = "sha256-7cE5nGXe48j3ArdHi+3swmLHHOi8m6YWBUw6s1ikm4Q=";
    };
    paths = [ "annotations/src/main/java" ];    
  };

  javax-inject = buildJar rec {
    pname ="javax-inject";
    version = "1";
    src = fetchFromGitHub {
      owner = "javax-inject";
      repo = "javax-inject";
      rev = "${version}";
      hash = "sha256-/cgR2LZVRO5cFf5Os4SU1LDYR+IzMmaNizLMPS2gV+c=";
    };
    paths = [ "src" ];    
  };

  javax-annotation-api = buildJar rec {
    pname = "javax-annotation-api";
    version = "1.2";
    src = fetchurl {
      url = "mirror://maven/javax/annotation/javax.annotation-api/${version}/javax.annotation-api-${version}-sources.jar";
      hash = "sha256-i9CDM6wsGV4iTMQGOnL0qrPJgM9en7aUEw+tQWiWidA=";
    };
    unpackPhase = ''
      jar xf $src
    '';
    paths = [ "." ];
  };

  # https://repo1.maven.org/maven2/javax/servlet/servlet-api/2.5/servlet-api-2.5-sources.jar
  javax-servlet-api = buildJar rec {
    pname = "javax-servlet-api";
    version = "2.5";
    src = fetchurl {
      url = "mirror://maven/javax/servlet/servlet-api/${version}/servlet-api-${version}-sources.jar";
      hash = "sha256-3Vs12ln/BKv452P/QJuWN14cQ/sRbSZYDGgrtxWk/Fo=";
    };
    unpackPhase = ''
      jar xf $src
    '';
    paths = [ "." ];
  };

  cdi-api = {};

  asm = buildJar rec {
    pname = "asm";
    version = "9_2";
    src = fetchFromGitLab {
      domain = "gitlab.ow2.org";
      owner = "asm";
      repo = "asm";
      rev = "ASM_${version}";
      hash = "sha256-k5YNsWwh/9WGE1a64daO6xdHOGCzzqja/Z8oM0TqCuM=";
    };
    paths = [
      "asm/src/main/java"
    ];
  };

  aopalliance = buildJar rec {
    pname = "aopalliance";
    version = "1.0";
    src = fetchurl {
      url = "mirror://maven/aopalliance/aopalliance/${version}/aopalliance-${version}-sources.jar";
      hash = "sha256-5u+R1DmtqQRfQZx3VD6+BBbDzfxbBjRINDQXo+SnISM=";
    };
    unpackPhase = ''
      jar xf $src
    '';
    paths = [ "." ];
  };

  slf4jVersion = "1.7.36";

  slf4jSource = fetchFromGitHub {
    owner = "qos-ch";
    repo = "slf4j";
    rev = "v_${slf4jVersion}";
    hash = "sha256-A891wuusRHJJJHDTLqKgT6sRUFZQioAk1u1tpnbWbRY=";
  };
  
  slf4j-api = buildJar rec {
    pname = "slf4j-api";
    version = slf4jVersion;
    src = slf4jSource;
    paths = [ "slf4j-api/src/main/java" ];
  };
  
  maven-shared-utils = {};
  wagon-provider-api = {};

}

  ## Notes

  # Http stuff can be stripped, since it won't be used in nix-style builds.

  # An issue with building 3.3.9 is that some of the dependencies are so obscure
  # and old that there is literally no source code anymore for them on the web.

  # The build need to do this before the javac compilation:
  # - Generate injections index for the sisu container
  # - Generate sources form modello files


  # Idea:
  #
  # The goal is to build Java libraries from source.
  #
  # Most Java libraries build using Maven or Gradle.
  #
  # Both produce the dependency graph in pom.xml format. Would it be worth it to
  # extract package definitions from there? It contains information about name,
  # version and dependencies, but does not say where the source code is. Maybe a
  # map of artifact ids + versions to source locations would help there. There
  # would be a need to deduce the source URL based on e.g. version. The question
  # is whether then most projects build just build - then it would be worth it
  # to not have to manually be checking versions of each dependency in parent
  # poms etc.
  
