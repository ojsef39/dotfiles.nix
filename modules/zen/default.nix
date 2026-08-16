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

        spaces = {
          "Personal" = {
            id = "cf13a859-8f2f-4af2-b563-d8a456cc917d";
            icon = "chrome://browser/skin/zen-icons/selectable/planet.svg";
            container = containers."Personal".id;
            position = 1000;
            theme = {
              type = "gradient";
              colors = [
                {
                  red = 183;
                  green = 189;
                  blue = 248;
                  algorithm = "floating";
                  type = "explicit-lightness";
                }
              ];
              opacity = 0.8;
              texture = 0.1;
            };
          };
          "JHC" = {
            id = "41b9ce21-3927-483f-9173-e3919191c528";
            icon = "chrome://browser/skin/zen-icons/selectable/cloud.svg";
            container = containers."Personal".id;
            position = 2000;
            theme = {
              type = "gradient";
              colors = [
                {
                  red = 138;
                  green = 173;
                  blue = 244;
                  algorithm = "floating";
                  type = "explicit-lightness";
                }
              ];
              opacity = 0.5;
              texture = 0.5;
            };
          };
          "Work" = {
            # pins for this and more work related spaces are defined in nix-work repo
            id = "450c7d65-0b3f-41ca-8dca-7b46638bfe96";
            icon = "chrome://browser/skin/zen-icons/selectable/briefcase.svg";
            container = containers."Work".id;
            position = 3000;
            theme = {
              type = "gradient";
              colors = [
                {
                  red = 30;
                  green = 30;
                  blue = 27;
                  algorithm = "floating";
                  type = "explicit-lightness";
                }
              ];
              opacity = 0.5;
              texture = 0.5;
            };
          };
        };

        pins = {
          "YouTube" = {
            id = "7454f1b5-22d5-4f48-9004-61f7c49ccdb3";
            container = containers.Personal.id;
            url = "https://youtube.com";
            isEssential = true;
            position = 101;
          };
          "Proton" = {
            id = "7a01d935-eaae-403f-9b7d-e0ec0904801f";
            container = containers.Personal.id;
            url = "https://mail.proton.me";
            isEssential = true;
            position = 102;
          };
          "Jelly" = {
            id = "513d0b0f-42e5-4c98-b180-619441698aef";
            container = containers.Personal.id;
            url = "https://jelly.jhofer.de";
            isEssential = true;
            position = 103;
          };
          "Karma" = {
            id = "ca83ba4d-167f-40ce-8284-160736e11019";
            container = containers.Personal.id;
            url = "https://karma.hla1.jhofer.lan";
            isEssential = true;
            position = 104;
          };
          "Matrix" = {
            id = "ffd131bf-5e7a-4e7f-b088-5261b0176c19";
            url = "https://app.element.io";
            container = containers.Personal.id;
            isEssential = true;
            position = 105;
          };
          "AI" = {
            id = "0c05d607-3880-4d49-a962-6804b6b0d502";
            url = "https://ai.jhofer.org/";
            container = containers.Personal.id;
            isEssential = true;
            position = 106;
          };

          # Personal workspace pins
          "JustWatch" = {
            id = "9ebdef2c-6c7c-467a-9d81-28bebdb17654";
            url = "https://www.justwatch.com/de/lists/tv-show-tracking";
            container = containers.Personal.id;
            workspace = spaces."Personal".id;
            position = 201;
          };
          "Reddit" = {
            id = "6134667a-3c74-4f69-8f6b-a694a7664fb9";
            url = "https://www.reddit.com/";
            container = containers.Personal.id;
            workspace = spaces."Personal".id;
            position = 202;
          };
          "Mastodon" = {
            id = "6f859dea-2aff-41ea-9d41-ba3b99ff38c4";
            url = "https://mastodon.de/home";
            container = containers.Personal.id;
            workspace = spaces."Personal".id;
            position = 203;
          };
          "Chaos Social" = {
            id = "7455a4ec-c165-47da-87dc-11c8499539bd";
            url = "https://chaos.social/home";
            container = containers.Personal.id;
            workspace = spaces."Personal".id;
            position = 204;
          };

          # Trivia folder
          "Trivia" = {
            id = "82631586-8f23-450c-a2b3-48b1c490b3f6";
            container = containers.Personal.id;
            workspace = spaces."Personal".id;
            isGroup = true;
            isFolderCollapsed = true;
            position = 205;
          };
          "JetPunk" = {
            id = "56cee429-97ce-4933-b78e-155dbdb16e92";
            url = "https://www.jetpunk.com/";
            container = containers.Personal.id;
            workspace = spaces."Personal".id;
            folderParentId = "82631586-8f23-450c-a2b3-48b1c490b3f6";
            position = 206;
          };
          "WikiTrivia" = {
            id = "7256579c-4d81-46ae-aa1d-4ab046264c87";
            url = "https://wikitrivia.tomjwatson.com/";
            container = containers.Personal.id;
            workspace = spaces."Personal".id;
            folderParentId = "82631586-8f23-450c-a2b3-48b1c490b3f6";
            position = 207;
          };

          # JHC workspace pins
          "GitHub PRs" = {
            id = "bd9ab8c6-bd49-4765-b776-3cd0360c4284";
            url = "https://github.com/pulls?max_pr_age=none";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            position = 201;
          };
          "Fleet" = {
            id = "5ebc16a8-6e75-4a35-883e-4857642b2b91";
            url = "https://github.com/JHOFER-Cloud/fleet";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            position = 202;
          };
          "Slack" = {
            id = "15319ac1-5fa8-4a89-b68f-78d7753c155c";
            url = "https://jhofer.slack.com";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            position = 203;
          };
          "Pushover" = {
            id = "7995040d-7e29-4fa9-b2a5-3219d7407101";
            url = "https://client.pushover.net/";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            position = 204;
          };
          "BetterStack" = {
            id = "a569ad92-804d-47ce-9bd4-5e3055836642";
            url = "https://uptime.betterstack.com/team/t459242/status-pages/225777/reports";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            position = 205;
          };
          "Status" = {
            id = "7c80133f-2841-4230-bc49-bd293e6255d0";
            url = "https://status.jhofer.org";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            position = 206;
          };
          "Renovate" = {
            id = "165ff60e-6815-4c80-8c6b-26aa35174b33";
            url = "https://renovate.jhofer.org/";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            position = 207;
          };
          # HLA1 folder
          "HLA1" = {
            id = "9baf02c7-f996-4186-91a3-a93a23acdaa9";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            isGroup = true;
            isFolderCollapsed = true;
            position = 208;
          };
          "deskvms" = {
            id = "e59e2f2b-6478-42c7-8bb0-1b932d0a43c0";
            url = "https://deskvms.hla1.jhofer.lan/";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            folderParentId = "9baf02c7-f996-4186-91a3-a93a23acdaa9";
            position = 209;
          };
          "ups-a" = {
            id = "298b2ac7-dd3d-48fd-b571-f9bb91dc86db";
            url = "http://ups-a.hla1.jhofer.lan/";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            folderParentId = "9baf02c7-f996-4186-91a3-a93a23acdaa9";
            position = 210;
          };
          "pve" = {
            id = "5b1cbe14-77a8-4a3c-af51-2b7da420b111";
            url = "https://pve.hla1.jhofer.lan/";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            folderParentId = "9baf02c7-f996-4186-91a3-a93a23acdaa9";
            position = 211;
          };
          "pve-1-kvm" = {
            id = "ac1a9ea1-0135-496c-a7c9-5c2982e3be58";
            url = "https://pve-1-kvm.hla1.jhofer.lan";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            folderParentId = "9baf02c7-f996-4186-91a3-a93a23acdaa9";
            position = 212;
          };
          "bc1-cmc" = {
            id = "2cf2c1f8-889d-4db1-8828-e86e3e8202cb";
            url = "https://bc1-cmc.hla1.jhofer.lan";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            folderParentId = "9baf02c7-f996-4186-91a3-a93a23acdaa9";
            position = 213;
          };
          "bc1-b1-p2-idrac" = {
            id = "690393bf-d699-4d06-be69-8426fde6f373";
            url = "https://bc1-b1-p2-idrac.hla1.jhofer.lan/restgui/start.html";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            folderParentId = "9baf02c7-f996-4186-91a3-a93a23acdaa9";
            position = 214;
          };
          "bc1-b2-p3-idrac" = {
            id = "f344e89a-140c-472d-9ed7-5862c67b35cc";
            url = "https://bc1-b2-p3-idrac.hla1.jhofer.lan/restgui/start.html";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            folderParentId = "9baf02c7-f996-4186-91a3-a93a23acdaa9";
            position = 215;
          };

          "Energy Watchdog" = {
            id = "6ada4b2e-ed5a-43be-b3e6-966fecd03949";
            url = "https://grafana.hla1.jhofer.lan/d/energy-watchdog/energy-watchdog?from=now-12h&to=now&refresh=1m";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            position = 216;
          };
          "Rack Temps" = {
            id = "10bdc242-5fb3-459f-ae32-aa711c297a86";
            url = "https://grafana.hla1.jhofer.lan/d/rack_temps/rack-temps?orgId=1&from=now-6h&to=now&timezone=browser&var-ds_prometheus=aef9f9k9lvwn4b&var-job=node-exporter-proxmox&var-nodename=pve-1&var-node=pve-1.hla1.jhofer.lan&var-temp_sensors=$__all&refresh=5m";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            position = 217;
          };
          "Misc Overview" = {
            id = "950825df-59e8-4d51-a491-bb4226aecda2";
            url = "https://grafana.hla1.jhofer.lan/d/dcf5mhzhh7gyyoc/misc-overview?orgId=1&from=now-6h&to=now&timezone=browser&var-ds=aef9f9k9lvwn4b&refresh=30s";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            position = 218;
          };

          # Satisfactory folder
          "Satisfactory" = {
            id = "6a6d21ee-9ef3-456f-a4f2-78a82814ac75";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            isGroup = true;
            isFolderCollapsed = true;
            position = 219;
          };
          "satisfaction01-p1" = {
            id = "7b85e9fd-4b33-4321-bb5b-f747945cb0a7";
            url = "https://satisfaction01-p1.hla1.jhofer.lan/map";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            folderParentId = "6a6d21ee-9ef3-456f-a4f2-78a82814ac75";
            position = 220;
          };
          "Satisfactory (Grafana)" = {
            id = "dbddfbf3-fe78-4122-a64a-bfbf87a7ddec";
            url = "https://grafana.hla1.jhofer.lan/d/satisfactory-savegame-exporter/?from=now-6h&to=now";
            container = containers.Personal.id;
            workspace = spaces."JHC".id;
            folderParentId = "6a6d21ee-9ef3-456f-a4f2-78a82814ac75";
            position = 221;
          };
        };
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
