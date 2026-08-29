{
  description = "NixOS config for citadel (AMD), prothean (AMD+Nvidia), legion (handheld), omega (server) + nix-darwin for normandy (MacBook)";

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

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "git+https://github.com/gmodena/nix-flatpak";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # omega (home server) tracks stable; the desktop/laptop machines stay on unstable.
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    {
      home-manager,
      jovian,
      nix-darwin,
      nix-flatpak,
      nixpkgs,
      nixpkgs-stable,
      self,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "tadeucruz";

      mkHost =
        nixpkgsSource: hostname: extraModules:
        nixpkgsSource.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs username hostname; };
          modules = [
            ./hosts/${hostname}/configuration.nix

            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs username hostname; };
              home-manager.users.${username} = import ./home/hosts/${hostname}.nix;
            }
          ]
          ++ extraModules;
        };

      mkDarwin =
        hostname:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs username hostname; };
          modules = [
            ./hosts/${hostname}/configuration.nix

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs username hostname; };
              home-manager.users.${username} = import ./home/hosts/${hostname}.nix;
            }
          ];
        };

      # Headless server (omega): no flatpak, no home-manager. Tracks nixpkgs-stable.
      mkServer =
        nixpkgsSource: hostname: extraModules:
        nixpkgsSource.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs username hostname; };
          modules = [ ./hosts/${hostname}/configuration.nix ] ++ extraModules;
        };
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;

      nixosConfigurations = {
        citadel = mkHost nixpkgs "citadel" [ jovian.nixosModules.default ];
        prothean = mkHost nixpkgs "prothean" [ ];
        legion = mkHost nixpkgs "legion" [ jovian.nixosModules.default ];
        omega = mkServer nixpkgs-stable "omega" [ ];
      };

      darwinConfigurations = {
        normandy = mkDarwin "normandy";
      };
    };
}
