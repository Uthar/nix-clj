{ stdenv, lib, pkgs, fetchurl, bash, cpio, pkgconfig, file, which, unzip, zip, cups, freetype
, alsaLib, openjdk-bootstrap, perl, liberation_ttf, fontconfig, zlib, lndir
, libX11, libICE, libXrender, libXext, libXt, libXtst, libXi, libXinerama, libXcursor, libXrandr
, libjpeg, giflib
, gnumake42
, setJavaClassPath
, headless ? false
, enableGnome2 ? true, gtk3, glib, gnome2 
}:

let

  inherit (gnome2) gnome_vfs GConf;

  # when building a headless jdk, also bootstrap it with a headless jdk
  openjdk-bootstrap' = openjdk-bootstrap.override { inherit headless; };

  openjdk10 = stdenv.mkDerivation rec {
    pname = "openjdk" + lib.optionalString headless "-headless";
    version = "10.0.2+13";

    src = pkgs.fetchFromGitHub {
      owner = "openjdk";
      repo = "jdk10u";
      rev = "jdk-${version}";
      sha256 = "sha256-BsSTX7WkyVOX6OjO1WDI8RnH9j065nG8gC9Wlo6p9gY=";
    };

    outputs = [ "out" "jre" ];

    nativeBuildInputs = [ pkgconfig gnumake42 ];
    buildInputs = [
      cpio file which unzip zip perl openjdk-bootstrap' zlib cups freetype alsaLib
      libjpeg giflib libX11 libICE libXext libXrender libXtst libXt libXtst
      libXi libXinerama libXcursor libXrandr lndir fontconfig
    ] ++ lib.optionals (!headless && enableGnome2) [
      gtk3 gnome_vfs GConf glib
    ];

    patches = [
      ./fix-java-home-jdk10.patch
      ./read-truststore-from-env-jdk10.patch
      ./openjdk-10-idlj-reproducibility.patch 
      ./openjdk-10-pointer-comparison.patch 
      ./openjdk-10-setsignalhandler.patch
      ./openjdk-currency-time-bomb2.patch
    ] ++ lib.optionals (!headless && enableGnome2) [
      ./swing-use-gtk-jdk10.patch
    ];

    preConfigure = ''
      chmod +x configure
      substituteInPlace configure --replace /bin/bash "${bash}/bin/bash"

      configureFlagsArray=(
        "--with-boot-jdk=${openjdk-bootstrap'.home}"
        "--enable-unlimited-crypto"
        "--disable-debug-symbols"
        "--disable-freetype-bundling"
        "--with-zlib=system"
        "--with-giflib=system"
        "--with-stdc++lib=dynamic"

        # glibc 2.24 deprecated readdir_r so we need this
        # See https://www.mail-archive.com/openembedded-devel@lists.openembedded.org/msg49006.html
        "--with-extra-cflags=-Wno-error=deprecated-declarations -Wno-error=format-contains-nul -Wno-error=unused-result"
    ''
    + lib.optionalString headless "\"--enable-headless-only\""
    + ");"
    # https://bugzilla.redhat.com/show_bug.cgi?id=1306558
    # https://github.com/JetBrains/jdk8u/commit/eaa5e0711a43d64874111254d74893fa299d5716
    + lib.optionalString stdenv.cc.isGNU ''
      NIX_CFLAGS_COMPILE+=" -fcommon -fno-lifetime-dse -fno-delete-null-pointer-checks -std=gnu++98 -Wno-error"
    '';

    NIX_LDFLAGS= lib.optionals (!headless) [
      "-lfontconfig" "-lcups" "-lXinerama" "-lXrandr" "-lmagic"
    ] ++ lib.optionals (!headless && enableGnome2) [
      "-lgtk-3" "-lgio-2.0" "-lgnomevfs-2" "-lgconf-2"
    ];

    buildFlags = [ "images" ];

    installPhase = ''
      mkdir -p $out/lib/openjdk $out/share $jre/lib/openjdk

      cp -av build/*/images/jdk/* $out/lib/openjdk

      # Remove some broken manpages.
      rm -rf $out/lib/openjdk/man/ja*

      # Mirror some stuff in top-level.
      mkdir $out/include $out/share/man
      ln -s $out/lib/openjdk/include/* $out/include/
      ln -s $out/lib/openjdk/man/* $out/share/man/

      # jni.h expects jni_md.h to be in the header search path.
      ln -s $out/include/linux/*_md.h $out/include/

      # Copy the JRE to a separate output and setup fallback fonts
      cp -av build/*/images/jre $jre/lib/openjdk/
      mkdir $out/lib/openjdk/jre
      ${lib.optionalString (!headless) ''
        mkdir -p $jre/lib/openjdk/jre/lib/fonts/fallback
        lndir ${liberation_ttf}/share/fonts/truetype $jre/lib/openjdk/jre/lib/fonts/fallback
      ''}

      # Remove crap from the installation.
      rm -rf $out/lib/openjdk/demo
      ${lib.optionalString headless ''
        for d in $out/lib/openjdk/lib $jre/lib/openjdk/jre/lib; do
          rm ''${d}/{libjsound,libjsoundalsa,libfontmanager}.so
        done
      ''}

      lndir $jre/lib/openjdk/jre $out/lib/openjdk/jre

      # Remove duplicate binaries.
      for i in $(cd $out/lib/openjdk/bin && echo *); do
        if [ "$i" = java ]; then continue; fi
        if cmp -s $out/lib/openjdk/bin/$i $jre/lib/openjdk/jre/bin/$i; then
          ln -sfn $jre/lib/openjdk/jre/bin/$i $out/lib/openjdk/bin/$i
        fi
      done

      ln -s $out/lib/openjdk/bin $out/bin
      ln -s $jre/lib/openjdk/jre/bin $jre/bin
      ln -s $jre/lib/openjdk/jre $out/jre
    '';

    preFixup = ''
      # Set JAVA_HOME automatically.
      mkdir -p $out/nix-support
      cat <<EOF > $out/nix-support/setup-hook
      if [ -z "\$\{JAVA_HOME-}" ]; then export JAVA_HOME=$out/lib/openjdk; fi
      EOF
    '';

    postFixup = ''
      # Build the set of output library directories to rpath against
      LIBDIRS=""
      for output in $outputs; do
        LIBDIRS="$(find $(eval echo \$$output) -name \*.so\* -exec dirname {} \+ | sort | uniq | tr '\n' ':'):$LIBDIRS"
      done

      # Add the local library paths to remove dependencies on the bootstrap
      for output in $outputs; do
        OUTPUTDIR=$(eval echo \$$output)
        BINLIBS=$(find $OUTPUTDIR/bin/ -type f; find $OUTPUTDIR -name \*.so\*)
        echo "$BINLIBS" | while read i; do
          patchelf --set-rpath "$LIBDIRS:$(patchelf --print-rpath "$i")" "$i" || true
          patchelf --shrink-rpath "$i" || true
        done
      done

      # Test to make sure that we don't depend on the bootstrap
      for output in $outputs; do
        if grep -q -r '${openjdk-bootstrap'}' $(eval echo \$$output); then
          echo "Extraneous references to ${openjdk-bootstrap'} detected"
          exit 1
        fi
      done
    '';

    meta = with lib; {
      homepage = http://openjdk.java.net/;
      license = licenses.gpl2;
      description = "The open-source Java Development Kit";
      maintainers = with maintainers; [ edwtjo ];
      platforms = ["i686-linux" "x86_64-linux"];
    };

    passthru = {
      home = "${openjdk10}/lib/openjdk";
    };
  };
in openjdk10
