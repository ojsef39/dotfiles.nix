{
  config,
  pkgs,
  vars,
  ...
}: let
  # Define theme path based on operating system
  themeFile = "midnight-catppuccin-macchiato.theme.css";
  themePath =
    if pkgs.stdenv.isDarwin
    then "/Users/${vars.user.name}/Library/Application Support/vesktop/themes/${themeFile}"
    else "${config.xdg.configHome}/vesktop/themes/${themeFile}";
in {
  programs.nixcord = {
    enable = true;
    discord = {
      enable = true;
      vencord = {
        enable = false;
        package = pkgs.vencord;
      };
    };
    vesktop = {
      enable = true;
      package = pkgs.vesktop.overrideAttrs (previousAttrs: {
        patches =
          previousAttrs.patches
          ++ [
            (pkgs.fetchpatch {
              name = "micfix-68c19662909621f421bc4a896e9225e21d62b3ed.patch";
              url = "https://gist.githubusercontent.com/ojsef39/b8d8190008869b8a868b998494e3f95d/raw/68c19662909621f421bc4a896e9225e21d62b3ed/micfix.patch";
              sha256 = "sha256-orMoR0NmHKirNG/6qEr35gjKzkMjHltgkOzioo6gIfY=";
            })
          ];
      });
    };
    config = {
      useQuickCss = false;
      disableMinSize = true;
      frameless = true;
      enabledThemes = [themeFile];
      plugins = {
        alwaysAnimate.enable = true;
        betterFolders = {
          enable = true;
          sidebar = false;
          sidebarAnim = true;
          closeAllFolders = true;
          closeAllHomeButton = true;
          forceOpen = true;
        };
        anonymiseFileNames = {
          enable = true;
          anonymiseByDefault = true;
        };
        appleMusicRichPresence.enable = true;
        betterGifPicker.enable = true;
        betterRoleContext.enable = true;
        betterSettings.enable = true;
        betterUploadButton.enable = true;
        biggerStreamPreview.enable = true;
        callTimer.enable = true;
        clearURLs.enable = true;
        # customIdle = {
        #   enable = true;
        #   idleTimeout = 5.0;
        #   remainInIdle = true;
        # };
        crashHandler.enable = true;
        experiments = {
          enable = true;
          toolbarDevMenu = true;
        };
        fakeProfileThemes.enable = true;
        favoriteEmojiFirst.enable = true;
        favoriteGifSearch.enable = true;
        fixImagesQuality.enable = true;
        fullSearchContext.enable = true;
        gameActivityToggle.enable = true;
        imageZoom = {
          enable = true;
          size = 200.0;
        };
        memberCount.enable = true;
        mentionAvatars.enable = true;
        messageClickActions.enable = true;
        messageLatency.enable = true;
        messageLinkEmbeds.enable = true;
        noDevtoolsWarning.enable = true;
        noF1.enable = true;
        noOnboardingDelay.enable = true;
        permissionsViewer.enable = true;
        pinDMs.enable = true;
        plainFolderIcon.enable = true;
        previewMessage.enable = true;
        quickMention.enable = true;
        readAllNotificationsButton.enable = true;
        reverseImageSearch.enable = true;
        sendTimestamps.enable = true;
        summaries.enable = true;
        shikiCodeblocks = {
          enable = true;
          theme = "https://raw.githubusercontent.com/shikijs/textmate-grammars-themes/refs/heads/main/packages/tm-themes/themes/catppuccin-macchiato.json";
        };
        translate.enable = true;
        typingIndicator.enable = true;
        typingTweaks.enable = true;
        validReply.enable = true;
        viewRaw.enable = true;
        voiceChatDoubleClick.enable = true;
        webScreenShareFixes.enable = true;
        whoReacted.enable = true;
      };
    };
  };

  # Download theme file
  home.file = {
    ${themePath} = {
      source = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/refact0r/midnight-discord/refs/heads/master/themes/flavors/midnight-catppuccin-macchiato.theme.css";
        sha256 = "01gasg6krkw9phh24pya95l7pam5125z6db3n3casjd7cj046i6h";
      };
      force = true;
    };
    # Settings configuration
    "${config.programs.nixcord.vesktop.configDir}/settings.json" = {
      text = builtins.toJSON {
        discordBranch = "stable";
        minimizeToTray = true;
        arRPC = true;
        customTitleBar =
          if pkgs.stdenv.isDarwin
          then true
          else false;
      };
      force = true;
    };
    # Quick CSS configuration
    "${config.programs.nixcord.vesktop.configDir}/settings/quickCss.css" = {
      text = ''
        .titleBar_a934d8 {
          display: none !important;
        }
      '';
      force = true;
    };
  };
}
