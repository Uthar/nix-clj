
# Clojure with packages
cwp () {
    local pkgs=$@;
    nix build \
        --impure \
        --expr "with builtins; with getFlake \"$(pwd)\"; (getAttr currentSystem packages).clojure.withPackages (ps: with ps; [ $pkgs ])"
}

# Clojure with packages in Docker
cwp+docker () {
    local pkgs=$@;
    nix bundle --bundler github:NixOS/bundlers#toDockerImage \
        --impure \
        --expr "with builtins; with getFlake \"$(pwd)\"; (getAttr currentSystem packages).clojure.withPackages (ps: with ps; [ $pkgs ])"
}

cwp+uberjar () {
    local name=$1;
    shift
    local pkgs=$@;
    nix build \
        --impure \
        --expr "with builtins; with getFlake \"$(pwd)\"; let clojure = (getAttr currentSystem packages).clojure; in clojure.buildUberjar \"$name\" (with clojure.pkgs; [ $pkgs ])"
}

