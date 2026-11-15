{
  description = "kawaii-wiki.ts development environment (Bun toolchain, pinned)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      # Match the version pinned in package.json (packageManager / engines.bun).
      # nixpkgs ships a slightly older Bun, so we pin the official release
      # binary per system to keep local dev byte-for-byte with CI.
      bunVersion = "1.4.4";

      # `nix store prefetch-file` hashes for
      #   https://github.com/oven-sh/bun/releases/download/bun-v${bunVersion}/bun-<asset>.zip
      bunAssets = {
        "x86_64-linux" = {
          asset = "linux-x64";
          hash = "sha256-v4zL+ysLgBWeD5ptFcVTF63YB3U028YTCj7bUvzLOVw=";
        };
        "aarch64-linux" = {
          asset = "linux-aarch64";
          hash = "sha256-uqa7NvUdblhWHgK76oJQOKnfRU9nPW13bou/hvjHhQ4=";
        };
        "aarch64-darwin" = {
          asset = "darwin-aarch64";
          hash = "sha256-wkDX8My5DCY6hJ/NsJt+5iYw2SE0jtaq/ahrnVd7xRA=";
        };
      };

      systems = builtins.attrNames bunAssets;
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pin = bunAssets.${system};
          bun = pkgs.bun.overrideAttrs (old: {
            version = bunVersion;
            src = pkgs.fetchurl {
              url = "https://github.com/oven-sh/bun/releases/download/bun-v${bunVersion}/bun-${pin.asset}.zip";
              hash = pin.hash;
            };
          });
        in
        {
          default = pkgs.mkShell {
            packages = [
              bun
              pkgs.git
            ];
            shellHook = ''
              echo "kawaii-wiki.ts devshell — bun $(bun --version)"
            '';
          };
        }
      );
    };
}
