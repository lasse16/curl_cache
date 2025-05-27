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
    #
    # # Utilized by `nix build .`
    # defaultPackage.x86_64-linux = c-hello.defaultPackage.x86_64-linux;
    #

    packages.${system}.default = pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "curl_cache";
      version = "0.4.0";

      src = ./.;

      buildInputs = with pkgs; [bashly];

      buildPhase = ''
        runHook preBuild

        bashly generate

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir $out/
        cp curl_cache $out/

        runHook postInstall

      '';
    });

    #
    # # Utilized by `nix run .#<name>`
    # apps.x86_64-linux.hello = {
    #   type = "app";
    #   program = c-hello.packages.x86_64-linux.hello;
    # };
    #
    # # Utilized by `nix run . -- <args?>`
    # defaultApp.x86_64-linux = self.apps.x86_64-linux.hello;
    #
    # # Utilized for nixpkgs packages, also utilized by `nix build .#<name>`
    # legacyPackages.x86_64-linux.hello = c-hello.defaultPackage.x86_64-linux;
    #

    devShell.${system} = pkgs.mkShell {
      name = "curl_cache";
      packages = with pkgs; [bashly];
    };
  };
}
