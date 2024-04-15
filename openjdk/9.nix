{ stdenv, lib, fetchFromGitHub, pkg-config, lndir, bash, cpio, file, which, unzip, zip
, cups, freetype, alsa-lib, cacert, perl, liberation_ttf, fontconfig, zlib
, libX11, libICE, libXrender, libXext, libXt, libXtst, libXi, libXinerama, libXcursor, libXrandr
, libjpeg, giflib
, openjdk-bootstrap
, setJavaClassPath
, headless ? false
}:

stdenv.mkDerivation rec {
  pname = "openjdk";
  version = "9+181";

  src = fetchFromGitHub {
    owner = "openjdk";
    repo = "jdk9u";
    rev = "jdk-${version}";
    sha256 = "sha256-sEVA44UPCQGH58uA3J/ppLAG6n0cXgrzM5ilEPc7DPE=";
  };

  # patches = [
  #   ./patches/9/jdk9-unneeded-check.patch
  # ];

  outputs = [ "out" "jre" ];

  nativeBuildInputs = [ pkg-config lndir unzip ];
  
  buildInputs = [
    cpio file which zip perl zlib cups freetype alsa-lib
    libjpeg giflib libX11 libICE libXext libXrender libXtst libXt libXtst
    libXi libXinerama libXcursor libXrandr fontconfig openjdk-bootstrap
  ];

  preConfigure = ''
    chmod +x configure
    substituteInPlace configure --replace /bin/bash ${stdenv.shell}
  '';

  configureFlags = [
    "--with-boot-jdk=${openjdk-bootstrap.home}"
    "--with-milestone=fcs"
    "--enable-unlimited-crypto"
    "--with-native-debug-symbols=internal"
    "--disable-freetype-bundling"
    "--with-zlib=system"
    "--with-giflib=system"
    "--with-stdc++lib=dynamic"
  ] ++ lib.optional headless "--disable-headful";

  separateDebugInfo = true;

  env.NIX_CFLAGS_COMPILE = toString ([
    "-Wno-error=deprecated-declarations"
  ] ++ lib.optionals stdenv.cc.isGNU [
    "-fno-lifetime-dse"
    "-fno-delete-null-pointer-checks"
    "-std=gnu++98"
    "-Wno-error"
  ]);

  NIX_LDFLAGS= toString (lib.optionals (!headless) [
    "-lfontconfig" "-lcups" "-lXinerama" "-lXrandr" "-lmagic"
  ]);

  # buildFlags = [ "all" ];

  disallowedReferences = [ openjdk-bootstrap ];

  meta.mainProgram = "java";

}
