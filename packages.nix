{ buildClojureLibrary, fetchFromGitHub, fetchMavenArtifact, ... }:

rec {

  # malli = buildClojureLibrary {
  #   pname = "malli";
  #   version = "0.9.2";
  #   src = fetchFromGitHub {
  #     owner = "metosin";
  #     repo = "malli";
  #     rev = "0.9.2";
  #     hash = "";
  #   };
  #   deps = [ dynaload edamame ];
  # };

  # dynaload = buildClojureLibrary {
  #   pname = "dynaload";
  #   version = "0.3.5";
  #   src = fetchFromGitHub {
  #     owner = "borkdude";
  #     repo = "dynaload";
  #     rev = "v0.3.5";
  #     hash = "";
  #   };
  # };

  # edamame = buildClojureLibrary {
  #   pname = "edamame";
  #   version = "1.0.16";
  #   src = fetchFromGitHub {
  #     owner = "borkdude";
  #     repo = "edamame";
  #     rev = "v1.0.16";
  #     hash = "";
  #   };
  #   deps = [ toolsReader ];
  # }
  # ;
  
  farolero = buildClojureLibrary {
    pname = "farolero";
    version = "1.4.4";
    src = fetchFromGitHub {
      owner = "IGJoshua";
      repo = "farolero";
      rev = "v1.4.4";
      hash = "sha256-qshbYUqp3ENY9L+bDnssZgnyGLksRg64Gqr9WFTEp/8=";
    };
    path = "src/cljc:src/java";
    deps = [ macrovich ];
  };

  macrovich = buildClojureLibrary {
    pname = "macrovich";
    version = "0.2.1";
    src = fetchFromGitHub {
      owner = "cgrand";
      repo = "macrovich";
      rev = "e80fb37cb795201821d0e75f73119802227e9620";
      hash = "sha256-jM1FYk9sLRKRQuf31OD8Z21VrDUH8UW5U/cqr9Z+3BA=";
    };
    ns = [ "net.cgrand.macrovich" ];
  };

  toolsGitlibs = buildClojureLibrary rec {
    pname = "tools.gitlibs";
    version = "v2.4.181";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-86QCuNTm5i8odZZgiehzRnXtpC8lKcybgq+rMVw6DLU=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.tools.gitlibs" ];
  };

  toolsCli = buildClojureLibrary rec {
    pname = "tools.cli";
    version = "v1.0.214";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-ocd5ACZXF3uqRn1RPN6rHD19unP3mTYyAIZC0jhD4gA=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.tools.cli" ];
  };

  toolsLogging = buildClojureLibrary rec {
    pname = "tools.logging";
    version = "v1.2.4";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-6vwtlT90GzEdnhhcdEJpBd0fJVL/2hx9+19VVY4OlO0=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.tools.logging" ];
  };
  
  toolsReader = buildClojureLibrary rec {
    pname = "tools.reader";
    version = "v1.3.6";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-SICGhCl9bMIQ5b6GBlGpHvNLLdzSPNSUeOVrTwTAmGU=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.tools.reader" ];
  };

  toolsAnalyzer = buildClojureLibrary rec {
    pname = "tools.analyzer";
    version = "v1.1.0";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-cAegZdNIQa43RZIoPTfRmUY64tpkUA6FmeOPrVbvj6U=";
    };
    path = "src/main/clojure";
    ns = [
      "clojure.tools.analyzer"
      "clojure.tools.analyzer.ast"
      "clojure.tools.analyzer.passes"
      "clojure.tools.analyzer.passes.trim"
      "clojure.tools.analyzer.passes.warn-earmuff"
      "clojure.tools.analyzer.passes.uniquify"
      "clojure.tools.analyzer.passes.add-binding-atom"
      "clojure.tools.analyzer.passes.cleanup"
      "clojure.tools.analyzer.passes.constant-lifter"
      "clojure.tools.analyzer.passes.emit-form"
      "clojure.tools.analyzer.passes.source-info"
    ];
  };

  toolsAnalyzerJvm = buildClojureLibrary rec {
    pname = "tools.analyzer.jvm";
    version = "v1.2.2";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-ecWRFtfjn0mpIjsJEJ/iDuiQlXzJuQtaoSgYotx+e8U=";
    };
    path = "src/main/clojure";
    ns = [
      "clojure.tools.analyzer.jvm"
      "clojure.tools.analyzer.passes.jvm.annotate-loops"
    ];
    deps = [ toolsAnalyzer coreMemoize coreCache dataPriorityMap asm toolsReader ];
  };

  toolsDepsAlpha = buildClojureLibrary rec {
    pname = "tools.deps.alpha";
    version = "v0.15.1244";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-8Vh+L2BwABU9Gz34ySoGJ1IpIPfvoP1ZZdIllq2yDJ4=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.tools.deps.alpha" ];
    deps = jars ++ [
      dataXml
      toolsCli
      toolsGitlibs
      coreAsync
      toolsLogging
      coreMemoize
      toolsAnalyzer
      toolsReader
      toolsAnalyzerJvm
      coreCache
      dataPriorityMap
      awsApi
    ];
  };
 
  jars = map fetchMavenArtifact (builtins.fromJSON (builtins.readFile ./jars.json));

  toolsBuild = buildClojureLibrary rec {
    pname = "tools.build";
    version = "v0.8.1";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-nuPBuNQ4su6IAh7rB9kX/Iwv5LsV+FOl/uHro6VcL7c=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.tools.build.api" ];
    deps = [ toolsDepsAlpha toolsNamespace ];
  };
  
  toolsNamespace = buildClojureLibrary rec {
    pname = "tools.namespace";
    version = "v1.3.0";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-vsUEFuXYrfhruhfEyBHQmYaEV1lSzjFzvdHizgp8IWw=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.tools.namespace" ];
  };

  dataXml = buildClojureLibrary rec {
    pname = "data.xml";
    version = "v0.2.0-alpha8";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-fRBd4eSAcJWtbIWGb0EyXJTywbLOicnlkaSP3RqJ69Y=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.data.xml" ];
  };

  dataJson = buildClojureLibrary rec {
    pname = "data.json";
    version = "v2.4.0";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-JQsLDr028FLfpZvtts0d2oLlaFBYjUc8gTdnYXyEo/c=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.data.json" ];
  };

  dataPriorityMap = buildClojureLibrary rec {
    pname = "data.priority-map";
    version = "v1.1.0";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-oE4f4xlp/Y+LfGVj92u5K9Dkm63JIB1zVXtQ8VJx1cQ=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.data.priority-map" ];
  };
  
  awsApi = buildClojureLibrary rec {
    pname = "aws-api";
    version = "v0.8.612";
    src = fetchFromGitHub {
      owner = "cognitect-labs";
      repo = pname;
      rev = version;
      hash = "sha256-YDHyzDq9hDkfaSULqu1QKYz7QPuRPLFK2nZn0aQPcTQ=";
    };
    ns = [ "cognitect.aws.client.api" ];
    deps = [ dataXml dataJson toolsLogging coreAsync ];
  };
  
  coreAsync = buildClojureLibrary rec {
    pname = "core.async";
    version = "v1.6.673";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-1kY/aTli9CnyhXI0ZwT6wlLFfGRGayA/4QSK21sWjv8=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.core.async" ];
    deps = [ toolsAnalyzerJvm ];
  };
  
  coreCache = buildClojureLibrary rec {
    pname = "core.cache";
    version = "v1.0.225";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-1ByBxHVTIqFHukEp9fk/eHQOWP3PP7KXaas5dzy9Ibc=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.core.cache" ];
    deps = [ dataPriorityMap ];
  };

  coreMemoize = buildClojureLibrary rec {
    pname = "core.memoize";
    version = "v1.0.257";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = version;
      hash = "sha256-XvkjzRKB/gAN2nXcq9IEF6cwtX9DNlZft6UZjzcsiG4=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.core.memoize" ];
    deps = [ coreCache dataPriorityMap ];
  };

  asm = fetchMavenArtifact {
    groupId = "org.ow2.asm";
    artifactId = "asm";
    version = "9.2";
    hash = "sha256-udT+TXGTjfOIOfDspCqqpkz4sxPWeNoDbwyzyhmbR/U=";
  };

  javaClasspath = buildClojureLibrary rec {
    pname = "java.classpath";
    version = "1.1.0";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = pname;
      rev = "c93196693a1705421d88c30120fb773941414c90";
      hash = "sha256-kguqLNmxt1aZggExnIrkEbRpDtufjsMFalOnsB+rlzU=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.java.classpath" ];
  };

  brewInstall = buildClojureLibrary {
    pname = "exec";
    version = "1.11.1.1200";
    src = fetchFromGitHub {
      owner = "clojure";
      repo = "brew-install";
      rev = "v1.11.1.1200";
      hash = "sha256-a5ZhSDPnUgiPARhE8/Mn7yrH46gcv0rZTU0gVUCG0os=";
    };
    path = "src/main/clojure";
    ns = [ "clojure.run.exec" ];
    deps = [ toolsDepsAlpha ];
  };

  nrepl = buildClojureLibrary {
    pname = "nrepl";
    version = "1.0.0";
    src = fetchFromGitHub {
      owner = "nrepl";
      repo = "nrepl";
      rev = "1.0.0";
      hash = "sha256-tCaLLVT7xtpxU8X+RzowoLsP8gp83XB8sVaFDwgO9OU=";
    };
    path = "src/clojure:src/java";
    ns = [ "nrepl.cmdline" ];
  };

  ciderNrepl = buildClojureLibrary {
    pname = "cider-nrepl";
    version = "0.28.7";
    src = fetchFromGitHub {
      owner = "clojure-emacs";
      repo = "cider-nrepl";
      rev = "v0.28.7";
      hash = "sha256-4hAhBPBFbCRXzeJFVBy5wIIZqOSqtrMTdrrHVpJSW2I=";
    };
    path = "src:resources";
    ns = [ "cider.nrepl" ];
  };

}
