{
  description = "A template that shows all standard flake outputs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = all @ {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    # # Utilized by `nix flake check`
    # checks.x86_64-linux.test = "tests";

    packages.${system}.default = pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "curl_cache";
      version = "0.5.0";

      src = ./.;

      nativeBuildInputs = with pkgs; [bashly pandoc installShellFiles];

      buildPhase = ''
        runHook preBuild

        bashly generate
        bashly add completions_script
        bashly render :mandoc docs

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        installBin curl_cache

        runHook postInstall
      '';

      postInstall = ''
        installShellCompletion --bash --name curl_cache.bash completions.bash
        installManPage docs/curl_cache.1
      '';
    });

    # Utilized for nixpkgs packages, also utilized by `nix build .#<name>`
    legacyPackages.${system}.curl_cache = self.packages.${system}.default;

    devShell.${system} = pkgs.mkShell {
      name = "curl_cache";
      packages = with pkgs; [bashly];
    };
  };
}
