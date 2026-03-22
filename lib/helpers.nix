_: rec {
  # Return the 1Password SSH agent socket path for the given platform.
  # Usage: baseLib.mkOpAgentSock pkgs
  mkOpAgentSock = pkgs:
    if pkgs.stdenv.isDarwin
    then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else "~/.1password/agent.sock";

  # Build the home directory path for the given platform.
  # Usage: baseLib.mkHome vars pkgs
  mkHome = vars: pkgs:
    if pkgs.stdenv.isDarwin
    then "/Users/${vars.user.name}"
    else "/home/${vars.user.name}";

  # Build the absolute dotfiles repository path for the given platform.
  # Usage: baseLib.mkDotPath vars pkgs
  mkDotPath = vars: pkgs: "${mkHome vars pkgs}/${vars.git.ghq}/${vars.git.dotfiles}";

  # Create an overlay that exposes packages with custom vars
  # Usage: nixpkgs.overlays = [(base.lib.makeOverlay vars)];
  makeOverlay = vars: _final: prev:
    import ../packages {
      pkgs = prev;
      inherit vars;
    };

  # Build the home-manager wiring module list for a given platform.
  # hmModule:      home-manager.darwinModules.home-manager or .nixosModules.home-manager
  # nixkitModule:  nixkit.darwinModules.default or .nixosModules.default
  # platformImport: ./modules/darwin/import-hm.nix or ./modules/nixos/import-hm.nix
  mkHomeManagerModules = {
    hmModule,
    nixkitModule,
    platformImport,
    inputs,
    baseLib,
    extraHmModules ? [],
  }: [
    hmModule
    nixkitModule
    (
      {vars, ...}: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = {
            inherit vars inputs baseLib;
          };
          users.${vars.user.name} = import ../modules/shared/import-hm.nix;
          sharedModules =
            [
              inputs.nix-index-database.homeModules.default
              inputs.nixcord.homeModules.nixcord
              inputs.nixkit.homeModules.default
              inputs.spicetify-nix.homeManagerModules.default
              inputs.zen-browser.homeModules.beta
            ]
            ++ extraHmModules;
        };
      }
    )
    (
      {vars, ...}: {
        home-manager.users.${vars.user.name} = import platformImport;
      }
    )
  ];
}
