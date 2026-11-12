{lib, ...}: {
  # The one thing a consuming configuration must supply. An option rather than a
  # specialArg so missing keys are named errors, defaults live in one place, and
  # a consumer can override a single key. Freeform: consumers may add own keys.
  # `_module.args.vars` keeps the plain `{vars, ...}:` signature working.
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
                projectDirs = lib.mkOption {
                  type = lib.types.str;
                  default = "~/.config";
                  description = "Space separated dirs whose subfolders the kitty and Rex project pickers offer next to the ghq repos.";
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
                signingKey = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "SSH public key commits are signed with (via 1Password). null disables signing.";
                };
                lazy.authorColors = lib.mkOption {
                  type = lib.types.attrsOf lib.types.str;
                  default = {};
                  description = "lazygit author name to colour mapping.";
                };
              };

              cache.community = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Trust the community binary caches (nix-community, claude-code).";
              };

              cachix.push = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Push every local build to ojsef39.cachix.org via the post-build hook.";
              };

              cachix.ignorePatterns = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
                description = "Extra store path patterns the cachix push hook skips.";
              };

              onePassword.sshVaults = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
                description = "1Password vaults whose keys the SSH agent offers, in order. Empty leaves agent.toml unmanaged.";
              };

              masApps.enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Install Mac App Store apps via homebrew.";
              };

              nvim.cord.allowList = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
                description = "Workspace names or git remote substrings nvim's Discord presence may report; everything else is hidden.";
              };
            };
          }
        ];
      };
    };

    config._module.args.vars = config.vars;
  };
}
