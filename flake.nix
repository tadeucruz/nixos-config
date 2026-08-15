{
  description = "NixOS config for 3 machines: citadel (AMD), prothean (AMD+Nvidia), legion (handheld)";

  inputs = {
    awcc = {
      url = "github:tr1xem/AWCC";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nix-flatpak.url = "git+https://github.com/gmodena/nix-flatpak";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      home-manager,
      jovian,
      nix-cachyos-kernel,
      nix-flatpak,
      nixpkgs,
      self,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "tadeucruz";

      # "pinned" overlay = exact nixpkgs revision the kernel was cached against,
      # required for binary cache hits (avoids compiling the kernel locally).
      cachyosKernel = {
        nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
        nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
        nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
      };

      mkHost =
        nixpkgsSource: hostname: extraModules:
        nixpkgsSource.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs username hostname; };
          modules = [
            ./hosts/${hostname}/configuration.nix

            cachyosKernel
            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs username hostname; };
              home-manager.users.${username} = import ./home/${hostname}.nix;
            }
          ]
          ++ extraModules;
        };
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;

      nixosConfigurations = {
        citadel = mkHost nixpkgs "citadel" [ jovian.nixosModules.default ];
        prothean = mkHost nixpkgs "prothean" [ ];
        legion = mkHost nixpkgs "legion" [ jovian.nixosModules.default ];
      };
    };
}
