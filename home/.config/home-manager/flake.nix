{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;

      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkHm = system: username: homeDirectory:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit username homeDirectory;
          };
        };

      # IMPORTANT: hostnames must match what `hostname` prints on that machine
      hosts = {
        lima-dev-vm = {
          system = "aarch64-linux";
          users = {
            pedro = "/home/pedro";
            tester = "/home/tester";
          };
        };

        ubuntu2404 = {
          system = "aarch64-linux";
          users = {
            tester = "/home/tester";
          };
        };

        github-action-runner = {
          system = "x86_64-linux";
          users = {
            tester = "/home/tester";
          };
        };

        # example mac host
        # mbp = {
        #   system = "aarch64-darwin";
        #   users = {
        #     pedro = "/Users/pedro";
        #     alice = "/Users/alice";
        #   };
        # };
      };

      mkHostConfigs = host: cfg:
        lib.mapAttrs'
          (username: homeDirectory: {
            name = "${username}@${host}";
            value = mkHm cfg.system username homeDirectory;
          })
          cfg.users;

    in {
      homeConfigurations =
        lib.foldl' lib.recursiveUpdate { }
          (lib.mapAttrsToList mkHostConfigs hosts);
    };
}
