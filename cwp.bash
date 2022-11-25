
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

