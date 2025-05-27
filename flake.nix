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
      version = "0.4.0";

      src = ./.;

      nativeBuildInputs = with pkgs; [bashly];

      buildPhase = ''
        runHook preBuild

        bashly generate

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin 
        cp curl_cache $out/bin

        runHook postInstall
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
