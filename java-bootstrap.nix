{ pkgs, lib, stdenv, makeWrapper
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
      autoconf automake autoconf-archive libtool gettext
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
  };

}
