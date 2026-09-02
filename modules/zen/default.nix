{
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    ...
  }: {
    # https://github.com/0xc000022070/zen-browser-flake
    programs.zen-browser = let
      # Use policy.json for installing extensions because its robuster and not dependent on a
      # third part flake
      extensions = {
        "uBlock0@raymondhill.net" = {
          name = "uBlock Origin";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };

        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          name = "1Password";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
        "clipper@obsidian.md" = {
          name = "Obsidian Web Clipper";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/web-clipper-obsidian/latest.xpi";
          installation_mode = "force_installed";
        };
        "sponsorBlocker@ajay.app" = {
          name = "SponsorBlock";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          installation_mode = "force_installed";
        };
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          name = "Vimium";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
          installation_mode = "force_installed";
        };
        "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = {
          name = "Refined GitHub";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}/latest.xpi";
          installation_mode = "force_installed";
        };
        "containerise@kinte.sh" = {
          name = "Containerise";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/containerise/latest.xpi";
          installation_mode = "force_installed";
        };
        "addon@simplelogin" = {
          name = "SimpleLogin";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/simplelogin/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    in {
      enable = true;

      profiles."default" = let
        containers = {
          Personal = {
            color = "blue";
            icon = "fingerprint";
            id = 1;
          };
          Work = {
            color = "orange";
            icon = "briefcase";
            id = 2;
          };
        };

        # Every space owns its own file in ./_parts (skipped by import-tree),
        # exporting `{spaces, pins}`. The nix-work repo adds work pins on top.
        shared = {inherit containers;};

        essentials = import ./_parts/essentials.nix shared;
        personal = import ./_parts/space_personal.nix shared;
        jhc = import ./_parts/space_jhc.nix shared;
        work = import ./_parts/space_work.nix shared;

        spaces = personal.spaces // jhc.spaces // work.spaces;
        pins = essentials.pins // personal.pins // jhc.pins // work.pins;
      in {
        inherit containers spaces pins;
        spacesForce = true;
        containersForce = true;
        pinsForce = false;

        joinedTabs = {
          "Mastodon + Chaos Social" = {
            id = "mastodon-chaos-social-split";
            gridType = "vsep";
            tabs = [
              pins."Mastodon".id
              pins."Chaos Social".id
            ];
          };
          "BetterStack + Status" = {
            id = "betterstack-status-split";
            gridType = "vsep";
            tabs = [
              pins."BetterStack".id
              pins."Status".id
            ];
            sizes = [70 30];
          };
          "Energy Watchdog + Nut Dog" = {
            id = "energy-watchdog-nut-dog-split";
            gridType = "vsep";
            tabs = [
              pins."Energy Watchdog".id
              pins."Nut Dog".id
            ];
            sizes = [50 50];
          };
          "Rack Temps + Misc Overview" = {
            id = "rack-temps-misc-overview-split";
            gridType = "vsep";
            tabs = [
              pins."Rack Temps".id
              pins."Misc Overview".id
            ];
            sizes = [70 30];
          };
        };

        # Get Key IDs using jq -c '.shortcuts[] | {id, key, keycode, action}' ~/Library/Application\ Support/Zen/Profiles/default/zen-keyboard-shortcuts.json | fzf
        # https://github.com/0xc000022070/zen-browser-flake#configuration-options
        keyboardShortcuts = [
          # Change compact mode toggle to Ctrl+Alt+S
          {
            id = "zen-compact-mode-toggle";
            key = "[";
            modifiers = {
              control = false;
              alt = true;
            };
          }
          {
            id = "zen-split-view-vertical";
            key = "*";
            modifiers = {
              shift = true;
              control = true;
            };
          }

          {
            id = "zen-split-view-horizontal";
            key = "_";
            modifiers = {
              shift = true;
              control = true;
            };
          }
          # Disable the quit shortcut to prevent accidental closes
          {
            id = "key_quitApplication";
            disabled = true;
          }
        ];
        # Fails activation on schema changes to detect potential regressions
        # Find this in about:config or prefs.js of your profile
        keyboardShortcutsVersion = 20;

        settings = {
          # Zen-specific preferences
          "zen.glance.activation-method" = "shift";
          "zen.theme.gradient.show-custom-colors" = true;
          "zen.welcome-screen.seen" = true;
          "zen.theme.accent-color" = "#cba6f7";
          "zen.pinned-tab-manager.restore-pinned-tabs-to-pinned-url" = true;
          "zen.workspaces.continue-where-left-off" = true;
          "zen.workspaces.force-container-workspace" = true;
          "zen.view.compact.should-enable-at-startup" = false;
          "zen.view.compact.enable-at-startup" = false;
          "zen.view.use-single-toolbar" = false;
          "zen.urlbar.show-domain-only-in-sidebar" = false;

          # General preferences
          "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = true;
          "browser.fixup.domainsuffixwhitelist.lan" = true;
          "browser.tabs.warnOnClose" = true;

          # Permissions
          "permissions.default.shortcuts" = 1; # 0=Allow, 1=Block (https://github.com/zen-browser/desktop/issues/8894#issuecomment-3674583799)
        };

        search = {
          force = true; # Needed for nix to overwrite search settings on rebuild
          default = "kagi";
          engines = {
            duckai = {
              name = "KagiAI";
              urls = [
                {
                  template = "https://kagi.com/assistant?internet=true&q=%s";
                  params = [
                  ];
                }
              ];
              definedAliases = ["@ai"];
            };

            kagi = {
              name = "Kagi";
              urls = [
                {
                  template = "https://kagi.com/search?q={searchTerms}";
                  params = [
                    {
                      name = "query";
                      value = "searchTerms";
                    }
                  ];
                }
              ];

              # icon = lg";
              definedAliases = ["@kagi"]; # Keep in mind that aliases defined here only work if they start with "@"
            };

            # My NixOS Option and package search shortcut
            mynixos = {
              name = "My NixOS";
              urls = [
                {
                  template = "https://mynixos.com/search?q={searchTerms}";
                  params = [
                    {
                      name = "query";
                      value = "searchTerms";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@nx"]; # Keep in mind that aliases defined here only work if they start with "@"
            };
          };
        };
      };

      policies = {
        ExtensionSettings = lib.mapAttrs (_id: ext: removeAttrs ext ["name"]) extensions;
        # Disable features
        # DisableBuiltinPDFViewer = true;
        DisableFirefoxStudies = true;
        DisableFirefoxAccounts = false;
        DisableFirefoxScreenshots = true;
        DisableForgetButton = true;
        DisableMasterPasswordCreation = true;
        DisableProfileImport = true;
        DisableProfileRefresh = true;
        DisableSetDesktopBackground = true;
        DisplayMenuBar = "default-off";
        DisableTelemetry = true;
        DisableFormHistory = true;
        DisablePasswordReveal = true;
        DontCheckDefaultBrowser = true;

        # Privacy settings
        OfferToSaveLogins = false;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        PasswordManagerEnabled = false;

        # Tracking protection
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
          EmailTracking = true;
        };

        # Firefox Suggest
        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = true;
        };

        # Downloads and handlers
        DefaultDownloadDirectory = "$HOME/Downloads";
        PromptForDownloadLocation = false;
        # Handlers = {
        #   mimeTypes."application/pdf".action = "saveToDisk";
        # };

        # First run
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        ExtensionUpdate = false;
        SearchBar = "unified";

        # Cleanup on shutdown
        SanitizeOnShutdown = {
          Cache = true;
          Cookies = false;
          Downloads = false;
          FormData = true;
          History = false;
          Sessions = false;
          SiteSettings = false;
          OfflineApps = true;
          Locked = true;
        };
      };
    };
  };
}
