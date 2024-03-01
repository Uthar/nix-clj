{ pkgs, lib, stdenv, makeWrapper
, fetchurl
, fetchzip
, fetchFromSavannah
, fastjar
, libffi
, zlib
, zip
, unzip
, autoconf
, automake
, autoconf-archive
, libtool
, gettext
, texinfo
, coreutils
, diffutils
, gawk
, gnugrep
, pkg-config
, which
, cpio
, libxslt
, perl
, nss
, krb5
, pcsclite
# TODO strip out graphical stuff
, xorg
, libjpeg
, libpng
, giflib
, lcms2
, gtk2
, alsa-lib
, ... }:

# Java bootstrap from C++
#
# Thanks to Guix for doing it first, which helped a lot.
#
# Most rationale can be found in java-bootstrap.scm

rec {

  jikes = stdenv.mkDerivation rec {
    pname = "jikes";
    version = "1.22";
    src = fetchzip {
      url = "mirror://sourceforge/jikes/Jikes/jikes-${version}.tar.bz2";
      hash = "sha256-58FRyopZ855cyradP+Qa5fEHsMAUHBiCi+1eOzZZK/o=e3";
    };
  };

  classpath = stdenv.mkDerivation rec {
    pname = "classpath";
    version = "0.93";
    src = fetchzip {
      url = "mirror://gnu/classpath/classpath-${version}.tar.gz";
      hash = "sha256-dP4lmumUKkOlwWOFHncPnsxR2y3Qr6mE+K3eb+x5zbY=";
    };
    patches = [
      ./patches/classpath-miscompilation.patch
    ];
    nativeBuildInputs = [
      jikes
      fastjar
    ];
    configureFlags = [
      "--disable-Werror"
      "--disable-gmp"
      "--disable-gtk-peer"
      "--disable-gconf-peer"
      "--disable-plugin"
      "--disable-dssi"
      "--disable-alsa"
      "--disable-gjdoc"
      "--disable-examples"
    ];
  };

  jamvm-1 = stdenv.mkDerivation rec {
    pname = "jamvm-bootstrap-1";
    version = "1.5.1";
    src = fetchzip {
      url = "mirror://sourceforge/jamvm/jamvm/JamVM%20${version}/jamvm-${version}.tar.gz";
      hash = "sha256-tBdFKV5IyQ0XRajdbLasm3wJMy9YUsu5NBoNlVInZSc=";
    };
    # Remove precompiled software.
    postPatch = ''
      rm lib/classes.zip
    '';
    configureFlags = [
      "--with-classpath-install-dir=${classpath}"
      "--disable-int-caching"
      "--enable-runtime-reloc-checks"
      "--enable-ffi"
    ];
    buildInputs = [ jikes libffi zlib zip ];
  };

  # FIXME current timestamp is being put in $out
  ant-bootstrap = stdenv.mkDerivation rec {
    pname = "ant-bootstrap";
    version = "1.8.4";
    src = fetchzip {
      url = "mirror://apache/ant/source/apache-ant-${version}-src.tar.bz2";
      hash = "sha256-S9f+h+CIo/rQ5DUOHxN16tcJ57BQU/1wtq+yIlUbH64=";
    };
    postPatch = ''
      substituteInPlace build.xml \
        --replace 'depends="jars,test-jar"' 'depends="jars"'
    '';
    # jikes needs to be in here, so that the below ANT_OPTS finds in in PATH -
    # Otherwise a silent error occurs. Only through strace I found that it was
    # running execve on a non existent executable.
    nativeBuildInputs = [ jikes unzip zip ];
    buildPhase = ''
      export JAVA_HOME=${jamvm-1}
      export JAVACMD=${jamvm-1}/bin/jamvm
      export JAVAC=${jikes}/bin/jikes
      export CLASSPATH=${classpath}/share/classpath/glibj.zip
      export ANT_OPTS=-Dbuild.compiler=jikes
      export BOOTJAVAC_OPTS='-nowarn'
      mkdir $out
      sh bootstrap.sh -Ddist.dir=$out
    '';
    dontInstall = true;
  };

  ecj-bootstrap = stdenv.mkDerivation rec {
    pname = "ecj-bootstrap";
    version = "3.2.2";
    src = fetchzip {
      url = "http://archive.eclipse.org/eclipse/downloads/drops/R-${version}-200702121330/ecjsrc.zip";
      hash = "sha256-Hdt/yYaZOQOV8bKIQz+xouX8iPr2eV3z6zh9R376I3o=";
      stripRoot = false;
    };
    buildInputs = [ jikes fastjar makeWrapper ];
    buildPhase = ''
      jikes --classpath ${jamvm-1}/lib/rt.jar:${ant-bootstrap}/lib/ant.jar $(find -name '*.java')
    '';
    installPhase = ''
      mkdir -p $out/{bin,share/java}
      fastjar cf $out/share/java/ecj-${version}.jar .
      makeWrapper ${jamvm-1}/bin/jamvm $out/bin/javac \
        --prefix CLASSPATH : '.' \
        --prefix CLASSPATH : $out/share/java/ecj-${version}.jar \
        --add-flags -Xmx768m \
        --add-flags org.eclipse.jdt.internal.compiler.batch.Main \
        --add-flags -nowarn
    '';
  };

  classpath099 = stdenv.mkDerivation rec {
    pname = "classpath";
    version = "0.99";
    src = fetchzip {
      url = "mirror://gnu/classpath/classpath-${version}.tar.gz";
      hash = "sha256-nz+q6rqqAXzLoF0c6afZ7tNis8OFv8c9tWzixwgj/hg=";
    };
    nativeBuildInputs = [
      ecj-bootstrap
      jamvm-1
      fastjar
    ];
    configureFlags = [
      "JAVAC=${ecj-bootstrap}/bin/javac"
      "JAVA=${jamvm-1}/bin/jamvm"
      "GCJ_JAVAC_TRUE=no"
      "ac_cv_prog_java_works=yes" # trust me
      "--disable-Werror"
      "--disable-gmp"
      "--disable-gtk-peer"
      "--disable-gconf-peer"
      "--disable-plugin"
      "--disable-dssi"
      "--disable-alsa"
      "--disable-gjdoc"
      "--disable-examples"
    ];
  };

  classpath-devel = stdenv.mkDerivation rec {
    pname = "classpath";
    version = "0.99-trunk";
    src = fetchFromSavannah {
      repo = "classpath";
      rev = "e7c13ee0cf2005206fbec0eca677f8cf66d5a103";
      hash = "sha256-hEdXkMAcQDGK7uylusK48xk2Z1Ai6PFuFWJwbg7nWew=";
    };
    nativeBuildInputs = [
      classpath099 # for javah
      ecj-bootstrap
      jamvm-1
      fastjar
      autoconf automake autoconf-archive libtool gettext texinfo
    ];
    preConfigure = ''
      autoreconf -vif
    '';
    configureFlags = [
      "--with-javac=${ecj-bootstrap}/bin/javac"
      "JAVA=${jamvm-1}/bin/jamvm"
      "GCJ_JAVAC_TRUE=no"
      "ac_cv_prog_java_works=yes" # trust me
      "--disable-Werror"
      "--disable-gmp"
      "--disable-gtk-peer"
      "--disable-gconf-peer"
      "--disable-plugin"
      "--disable-dssi"
      "--disable-alsa"
      "--disable-gjdoc"
      "--disable-examples"
    ];
    postPatch = ''
      substituteInPlace $(grep -l -r '@Override') --replace @Override "" 
    '';
    # Not sure what this does.
    postInstall = ''
      make install-data
    '';
  };

  jamvm = stdenv.mkDerivation rec {
    pname = "jamvm";
    version = "2.0.0";
    src = fetchzip {
      url = "mirror://sourceforge/jamvm/jamvm/JamVM%20${version}/jamvm-${version}.tar.gz";
      hash = "sha256-FSL2x2C3a3RQ88pRokZQ6dbXcgZFbZLiIZ6MfsFY70Y=";
    };
    patches = [
      patches/jamvm-2.0.0-disable-branch-patching.patch
      patches/jamvm-2.0.0-opcode-guard.patch
    ];
    # Remove precompiled software.
    postPatch = ''
      rm src/classlib/gnuclasspath/lib/classes.zip
    '';
    configureFlags = [
      "--with-classpath-install-dir=${classpath-devel}"
    ];
    buildInputs = [ ecj-bootstrap zlib zip ];
  };

  ecj-javac-wrapper-new-jamwm-2 = stdenv.mkDerivation rec {
    pname = "ecj-javac-wrapper";
    version = "2";
    dontUnpack = true;
    buildInputs = [ makeWrapper ];
    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${jamvm}/bin/jamvm $out/bin/javac \
        --prefix CLASSPATH : '.' \
        --prefix CLASSPATH : ${ecj-bootstrap}/share/java/ecj-${ecj-bootstrap.version}.jar \
        --add-flags -Xmx768m \
        --add-flags org.eclipse.jdt.internal.compiler.batch.Main \
        --add-flags -nowarn
    '';
  };

  ecj4-bootstrap = stdenv.mkDerivation rec {
    pname = "ecj-bootstrap";
    version = "4.2.1";
    src = fetchurl {
      url = "http://archive.eclipse.org/eclipse/downloads/drops4/R-${version}-201209141800/ecjsrc-${version}.jar";
      hash = "sha256-0mGyFY9ZhkDxkjgF0um/R+sh2DM/Ths39Z+EetANSPQ=";
    };
    unpackPhase = "gjar xf $src";
    postPatch = ''
      # This directive is not supported by our simple bootstrap JDK.
      substituteInPlace $(grep -l -r '@Override') --replace @Override ""

      # We can't compile these yet, but we don't need them at this point anyway.
      rm org/eclipse/jdt/core/JDTCompilerAdapter.java
      rm -r org/eclipse/jdt/internal/antadapter
    '';
    buildInputs = [ ecj-javac-wrapper-new-jamwm-2 classpath-devel makeWrapper ];
    buildPhase = ''
      javac -source 1.5 -target 1.5 -classpath ${jamvm}/lib/rt.jar:${ant-bootstrap}/lib/ant.jar $(find -name '*.java')
    '';
    installPhase = ''
      mkdir -p $out/{bin,share/java}
      gjar cf $out/share/java/ecj-${version}.jar .
      makeWrapper ${jamvm}/bin/jamvm $out/bin/javac \
        --prefix CLASSPATH : '.' \
        --prefix CLASSPATH : $out/share/java/ecj-${version}.jar \
        --add-flags -Xmx768m \
        --add-flags org.eclipse.jdt.internal.compiler.batch.Main \
        --add-flags -nowarn
    '';
  };

  jamvm-with-ecj4 = jamvm.overrideAttrs (o: {
    buildInputs = (lib.remove ecj-bootstrap o.buildInputs) ++ [ ecj4-bootstrap ];
  });

  # Can now start with openjdk:

  # https://web.archive.org/web/20080523171517/http://icedtea.classpath.org/wiki/DebianBuildingInstructions
  icedtea-7 = stdenv.mkDerivation rec {
    pname = "icedtea";
    version = "2.6.13";
    src = fetchzip {
      url = "http://icedtea.wildebeest.org/download/source/icedtea-${version}.tar.xz";
      hash = "sha256-lOj+rN15jRhnwOgAc4Duw/ppL1aCk1oJAAdHi+5I2Bg=";
    };
    patches = [ ./patches/icedtea7.patch ];
    postPatch = ''
      substituteInPlace acinclude.m4 \
        --replace 'attr/xattr.h' 'sys/xattr.h'
      substituteInPlace Makefile.am \
        --replace '$(SYSTEM_JDK_DIR)/jre/lib/rt.jar' \
                  '${classpath-devel}/share/classpath/glibj.zip'
    '';
    preConfigure = ''
      autoreconf -vfi
    '';
    # TODO a lot of this stuff seems unnecessary.
    configureFlags = [
      "--disable-system-sctp"
      "--enable-system-pcsc" # Needed?
      "--enable-system-lcms"
      "--enable-bootstrap"
      "--enable-nss"
      "--without-rhino"
      "--disable-downloading"
      # "--with-parallel-jobs=$NIX_BUILD_CORES" 
      "--disable-downloading"
      "--disable-tests"
      # "--with-openjdk-src-dir=./openjdk.src"
      "--with-ecj=${ecj4-bootstrap}/bin/javac"
      "--with-jdk-home=${classpath-devel}"
      "--with-java=${jamvm-with-ecj4}/bin/jamvm"
      "--with-jar=${classpath-devel}/bin/gjar"
    ];
    nativeBuildInputs = [
      automake
      autoconf
      ant-bootstrap
      classpath-devel
      coreutils
      diffutils
      ecj4-bootstrap
      fastjar #only for the configure phase; we actually use gjar
      gawk
      gnugrep
      jamvm-with-ecj4
      libtool
      pkg-config
      which
      cpio
      zip
      unzip
      libxslt
      perl
      nss
      zlib
      krb5
      pcsclite
      # TODO strip out graphical stuff from the jdk
      xorg.libX11
      xorg.libXt
      xorg.libXtst
      libjpeg
      libpng
      giflib
      lcms2
      gtk2
      alsa-lib
    ];
  };

  

}