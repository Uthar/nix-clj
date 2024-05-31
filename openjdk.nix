{ pkgs, lib, stdenv
, fetchFromGitHub
, openjdk-7
, ... }:

rec {

  openjdk-8 = pkgs.callPackage ./openjdk/8.nix {
    openjdk-bootstrap = openjdk-7;
  };  
  
  openjdk-9 = pkgs.callPackage ./openjdk/9.nix {
    openjdk-bootstrap = openjdk-8;
  };

  openjdk-10 = pkgs.callPackage ./openjdk/10.nix {
    openjdk-bootstrap = openjdk-9;
  };

  openjdk-11 = pkgs.callPackage ./openjdk/11.nix {
    openjdk-bootstrap = openjdk-10;
  };

  openjdk-12 = pkgs.callPackage ./openjdk/12.nix {
    openjdk-bootstrap = openjdk-11;
  };

  openjdk-13 = pkgs.callPackage ./openjdk/13.nix {
    openjdk-bootstrap = openjdk-12;
  };

  openjdk-14 = pkgs.callPackage ./openjdk/14.nix {
    openjdk-bootstrap = openjdk-13;
  };

  openjdk-15 = pkgs.callPackage ./openjdk/15.nix {
    openjdk-bootstrap = openjdk-14;
  };

  openjdk-16 = pkgs.callPackage ./openjdk/16.nix {
    openjdk-bootstrap = openjdk-15;
  };

  openjdk-17 = pkgs.callPackage ./openjdk/17.nix {
    openjdk-bootstrap = openjdk-16;
  };

  openjdk-18 = pkgs.callPackage ./openjdk/18.nix {
    openjdk-bootstrap = openjdk-17;
  };

  openjdk-19 = pkgs.callPackage ./openjdk/19.nix {
    openjdk-bootstrap = openjdk-18;
  };

  openjdk-20 = pkgs.callPackage ./openjdk/20.nix {
    openjdk-bootstrap = openjdk-19;
  };

  openjdk-21 = pkgs.callPackage ./openjdk/21.nix {
    openjdk-bootstrap = openjdk-20;
  };

  openjdk-22 = pkgs.callPackage ./openjdk/22.nix {
    openjdk-bootstrap = openjdk-21;
  };

}
