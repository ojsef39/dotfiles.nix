{lib, ...}: {
  # `vars` is the one thing a consuming configuration has to supply. Declaring it
  # as an option rather than passing it through `specialArgs` means:
  #   - a missing required key is a named option error, not `attribute 'ghq' missing`
  #     thrown from somewhere deep inside an unrelated module
  #   - optional keys carry their defaults here instead of being re-spelled as
  #     `or` fallbacks at every use site
  #   - a consumer can override one key (`vars.cache.community = true;`) without
  #     restating the whole attrset
  #
  # `_module.args.vars` re-exposes it so modules keep their plain `{vars, ...}:`
  # signature. The freeform type lets a downstream flake keep its own private
  # keys in the same attrset without this repo having to know about them.
  flake.modules.generic.base = {config, ...}: {
    options.vars = lib.mkOption {
      description = "Per-configuration identity and preferences.";
      type = lib.types.submoduleWith {
        modules = [
          {
            freeformType = lib.types.attrsOf lib.types.anything;

            options = {
              user = {
                name = lib.mkOption {
                  type = lib.types.str;
                  description = "Login name of the primary user.";
                };
                full_name = lib.mkOption {
                  type = lib.types.str;
                  description = "Display name of the primary user.";
                };
                email = lib.mkOption {
                  type = lib.types.str;
                  description = "Git/commit email of the primary user.";
                };
                uid = lib.mkOption {
                  type = lib.types.int;
                  default = 501;
                  description = ''
                    User id. Must be set on macOS, where management tooling
                    assumes the default 501 admin user.
                  '';
                };
              };

              git = {
                ghq = lib.mkOption {
                  type = lib.types.str;
                  default = "CodeProjects";
                  description = "Directory under $HOME that ghq clones into.";
                };
                dotfiles = lib.mkOption {
                  type = lib.types.str;
                  description = "ghq-style path of the dotfiles repo itself, e.g. github.com/ojsef39/dotfiles.nix.";
                };
                url = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "Primary git forge host. Empty disables the forge-specific ghq sync.";
                };
                customServices = lib.mkOption {
                  type = lib.types.listOf (lib.types.attrsOf lib.types.str);
                  default = [];
                  description = "Extra forges for git/nvim, as {domain, provider} pairs.";
                };
                lazy.authorColors = lib.mkOption {
                  type = lib.types.attrsOf lib.types.str;
                  default = {};
                  description = "lazygit author name to colour mapping.";
                };
              };

              kitty.project_selector = lib.mkOption {
                type = lib.types.str;
                default = "~/.config";
                description = "Space separated dirs offered by the kitty project selector.";
              };

              cache.community = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Trust the community binary caches (nix-community, claude-code).";
              };

              cachix.ignorePatterns = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
                description = "Extra store path patterns the cachix push hook skips.";
              };

              masApps.enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Install Mac App Store apps via homebrew.";
              };

              nvim.cord.ignoreList = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
                description = "Repos nvim's Discord presence must not report.";
              };
            };
          }
        ];
      };
    };

    config._module.args.vars = config.vars;
  };
}
