{ pkgs, lib, stdenv
, fetchFromGitHub
, openjdk-7
, ... }:

rec {

  openjdk-8 = pkgs.jdk8.override {
    openjdk8-bootstrap = openjdk-7 // {
      home = "${openjdk-7}";
    };
  };

  openjdk-9 = pkgs.callPackage ./openjdk/9.nix {
    openjdk-bootstrap = openjdk-8;
  };

  openjdk-10 = pkgs.callPackage ./openjdk/10.nix {
    bootjdk = openjdk-9;
  };

  openjdk-11 = pkgs.callPackage ./openjdk/11.nix {
    openjdk-bootstrap = openjdk-10;
  };

}
