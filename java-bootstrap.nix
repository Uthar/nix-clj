{ pkgs, lib, stdenv
, fetchzip
, fastjar
, libffi
, zlib
, zip
, ... }:

# Java bootstrap from C++
#
# Thanks to Guix for doing it first, which helped a lot.

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

}
