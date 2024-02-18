#!/bin/sh
nix build .#java.brotli-full
javac -cp result/share/java/brotli-full-1.0.0-SNAPSHOT.jar test.java
clj -Scp ".:$(clj -Spath):result/share/java/brotli-full-1.0.0-SNAPSHOT.jar" -J-Djava.library.path=result/lib
# Now load test.clj
