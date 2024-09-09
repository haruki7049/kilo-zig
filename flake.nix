{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    treefmt.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      treefmt,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        treefmtEval = treefmt.lib.evalModule pkgs ./treefmt.nix;
        zig = pkgs.zig_0_13;
      in
      {
        formatter = treefmtEval.config.build.wrapper;

        checks = {
          formatting = treefmtEval.config.build.check self;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            # Zig
            zig
            pkgs.zls

            # Nix
            pkgs.nil
          ];

          shellHook = ''
            export PS1="\n[nix-shell\w]$ "
          '';
        };
      }
    );
}
