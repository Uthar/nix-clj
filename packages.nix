{ buildClojureLibrary, fetchFromGitHub, ... }:

rec {

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

}
