{
  description = "NixOS config for 3 machines: htpc (AMD), g15 (AMD+Nvidia), legion (handheld)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    awcc = {
      url = "github:tr1xem/AWCC";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # Uncomment when ready to use Jovian (SteamOS-like kernel) on the Legion Go:
    # jovian = {
    #   url = "github:Jovian-Experiments/Jovian-NixOS";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "tadeucruz";

      mkHost = nixpkgsSource: hostname: extraModules:
        nixpkgsSource.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs username hostname; };
          modules = [
            ./hosts/${hostname}/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs username hostname; };
              home-manager.users.${username} = import ./home/${hostname}.nix;
            }
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        htpc   = mkHost nixpkgs        "htpc"   [ ];
        g15    = mkHost nixpkgs-stable "g15"    [ ];
        legion = mkHost nixpkgs        "legion" [ ];
      };
    };
}
