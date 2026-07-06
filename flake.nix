{
  description = "NixOS config for 3 machines: htpc (AMD), g15 (AMD+Nvidia), legion (handheld)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    awcc = {
      url = "github:tr1xem/AWCC";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # CachyOS kernel variants (htpc, legion). "release" branch = prebuilt + cached.
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, jovian, nix-cachyos-kernel, ... }@inputs:
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
        htpc   = mkHost nixpkgs        "htpc"   [ jovian.nixosModules.default cachyosKernel ];
        g15    = mkHost nixpkgs-stable "g15"    [ ];
        legion = mkHost nixpkgs        "legion" [ jovian.nixosModules.default cachyosKernel ];
      };
    };
}
