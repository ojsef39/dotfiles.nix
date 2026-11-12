# Rex terminal multiplexer. Based on frostplexx/dotfiles.nix (modules/home/rex).
#
# Caveats vs. the kitty/Ghostty/tmux setup — things Rex cannot do:
# - Mouse buttons b4/b5 for tab switching: Rex has no mouse bindings. Remap the
#   side buttons to ctrl+tab / ctrl+shift+tab (Rex defaults) at the OS level.
# - ctrl+alt+n (<C-\><C-n>, leave nvim terminal mode) and the en/em dash on
#   alt+- / alt+shift+- send more than one key or a non-US character.
# - f1 scrollback-in-less, ctrl+shift+r layout rotate, tmux copy-mode tables.
{
  flake.modules.homeManager.base = {
    lib,
    pkgs,
    ...
  }: let
    # Rex keeps imported themes under Workspace.customThemes as JSON data, in
    # the shape Rex writes when it imports a Ghostty theme. Rex's generated
    # 16-255 palette is left empty (extended palettes stay off).
    hexDigits = {
      "0" = 0;
      "1" = 1;
      "2" = 2;
      "3" = 3;
      "4" = 4;
      "5" = 5;
      "6" = 6;
      "7" = 7;
      "8" = 8;
      "9" = 9;
      "a" = 10;
      "b" = 11;
      "c" = 12;
      "d" = 13;
      "e" = 14;
      "f" = 15;
    };

    hexDigit = char: hexDigits.${lib.toLower char};

    toRexColor = hex: {
      red = (hexDigit (builtins.substring 0 1 hex) * 16 + hexDigit (builtins.substring 1 1 hex)) / 255.0;
      green = (hexDigit (builtins.substring 2 1 hex) * 16 + hexDigit (builtins.substring 3 1 hex)) / 255.0;
      blue = (hexDigit (builtins.substring 4 1 hex) * 16 + hexDigit (builtins.substring 5 1 hex)) / 255.0;
      alpha = 1.0;
      colorSpace = "srgb";
    };

    # The colors are written out instead of fetched and parsed from the theme
    # file: reading a fetched file during evaluation is import-from-derivation,
    # which the CVE scan in CI does not allow.
    mkRexTheme = {
      name,
      id,
      appearance,
      fileName,
      colors,
    }: {
      inherit id name appearance;
      palette = {
        ansi = map toRexColor colors.ansi;
        background = toRexColor colors.background;
        foreground = toRexColor colors.foreground;
        cursor = toRexColor colors.cursor;
        cursorText = toRexColor colors.cursorText;
        selectionBackground = toRexColor colors.selectionBackground;
        selectionForeground = toRexColor colors.selectionForeground;
        paletteBase = {};
        paletteOverrides = {};
        paletteGenerate = false;
        paletteHarmonious = false;
      };
      source.ghosttyFile.fileName = fileName;
      createdAt = 0;
    };

    # Fixed ID so Workspace.darkThemeID / lightThemeID can point at it.
    # Macchiato for both appearances, like the Ghostty/kitty config. Colors from
    # catppuccin/ghostty@b0b03cc themes/catppuccin-macchiato.conf.
    catppuccinMacchiato = mkRexTheme {
      name = "Catppuccin Macchiato";
      id = "custom-3E8D6F21-9A4C-4B7E-8D15-6C2F0A9B4E77";
      appearance = "dark";
      fileName = "catppuccin-macchiato.conf";
      colors = {
        # ANSI 0-15
        ansi = [
          "494d64"
          "ed8796"
          "a6da95"
          "eed49f"
          "8aadf4"
          "f5bde6"
          "8bd5ca"
          "a5adcb"
          "5b6078"
          "ed8796"
          "a6da95"
          "eed49f"
          "8aadf4"
          "f5bde6"
          "8bd5ca"
          "b8c0e0"
        ];
        background = "24273a";
        foreground = "cad3f5";
        cursor = "f4dbd6";
        cursorText = "181926";
        selectionBackground = "3a3e53";
        selectionForeground = "cad3f5";
      };
    };

    rexThemeJSON = builtins.toJSON [catppuccinMacchiato];
  in
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      xdg.configFile."rex".source = ./config;
      ai.allowedBashCommands = ["rex session rename *"];

      # Rex's Claude Code session hook: what `rex skill setup` would add, but
      # ~/.claude/settings.json is a read-only store link. Tells Claude which Rex
      # session and pane it runs in (the skill itself Rex installs on its own).
      programs.claude-code.settings.hooks.SessionStart = [
        {
          hooks = [
            {
              type = "command";
              command = "/bin/sh -c 'rex __internal session-start --agent claude 2>/dev/null || true'";
              timeout = 5;
            }
          ];
        }
      ];

      home = {
        # `rex-track <command>` reports working/done/error for any command (OSC 7501)
        # `rex-k9s` opens k9s on talos-dev and talos-live side by side
        packages = [pkgs.rex-track pkgs.rex-k9s];

        # Rex Beta's download link is invite-only, so it lives in a sops file. Only
        # installs when missing: Rex updates itself (RexAppUpdateAutomation below).
        activation.rexInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
          if [ ! -d "/Applications/Rex Beta.app" ]; then
            rexTmp=$(/usr/bin/mktemp -d)
            if rexAgeKey=$(${pkgs._1password-cli}/bin/op read op://Personal/SOPS_AGE_KEY_FILE/credential) \
              && rexUrl=$(SOPS_AGE_KEY="$rexAgeKey" ${pkgs.sops}/bin/sops -d --extract '["REX_DMG_URL"]' ${./download.env}) \
              && [ -n "$rexUrl" ] \
              && run /usr/bin/curl -fsSL -o "$rexTmp/rex.dmg" "$rexUrl" \
              && run /usr/bin/hdiutil attach -quiet -nobrowse -readonly -mountpoint "$rexTmp/mnt" "$rexTmp/rex.dmg" \
              && run /usr/bin/ditto "$rexTmp/mnt/Rex Beta.app" "/Applications/Rex Beta.app"; then
              verboseEcho "Installed Rex Beta"
            else
              warnEcho "Rex Beta not installed: decrypting the URL or downloading the dmg failed"
            fi
            [ -d "$rexTmp/mnt" ] && /usr/bin/hdiutil detach -quiet "$rexTmp/mnt" || true
            /bin/rm -rf "$rexTmp"
          fi
        '';

        # The themes cannot go through targets.darwin.defaults: Rex keeps imported
        # themes as JSON data, which a plist attrset cannot express. Writing the key
        # replaces any themes imported in the app.
        activation.rexTheme = lib.hm.dag.entryAfter ["writeBoundary" "setDarwinDefaults"] ''
          themeHex=$(printf '%s' ${lib.escapeShellArg rexThemeJSON} | ${pkgs.coreutils}/bin/od -An -v -tx1 | ${pkgs.coreutils}/bin/tr -d ' \n')
          run /usr/bin/defaults write com.superlogical.rex 'Workspace.customThemes' -data "$themeHex"
        '';
      };

      # Rex stores its preferences as flat, dotted keys next to app state in one
      # domain. Only preferences are set here; `defaults import` merges.
      targets.darwin.defaults."com.superlogical.rex" = {
        RexAppUpdateAutomation = "install";
        RexAppUpdateChannel = "preview";

        "rex.agents.names-sessions" = true;
        # Needed for the experimental cursor shaders (Workspace.cursorShader)
        "rex.developer-mode-enabled" = true;
        # Needed by the project picker / scratch session to show new sessions
        "rex.client.remoteControl" = true;
        "rex.server.automatic-restart-enabled" = true;
        "rex.server.run-mode" = "bundled";

        "Workspace.activePaneBorderOpacity" = 0.5;
        "Workspace.activePaneBorderTransition" = "instant";
        "Workspace.animationStyle" = "snappy";
        "Workspace.darkThemeID" = catppuccinMacchiato.id;
        "Workspace.darkUsesExtendedThemePalette" = false;
        "Workspace.hiddenChromeButtons" = ["commandPalette" "newTab"];
        "Workspace.inactivePaneFadeMode" = "none";
        "Workspace.insertPathShowsRecentPaths" = true;
        "Workspace.interfaceStyle" = "blendTheme";
        "Workspace.lightThemeID" = catppuccinMacchiato.id;
        "Workspace.lightUsesExtendedThemePalette" = false;
        "Workspace.notificationPosition" = "top-center";
        "Workspace.paneDensity" = "compact";
        "Workspace.appIcon" = "twilight";
        "Workspace.appIconVisibility" = "dockOnly";
        "Workspace.shellIconTheme" = "themed";
        "Workspace.showsActivePaneBorder" = true;
        "Workspace.showsIdleProgramsInActivity" = true;
        "Workspace.showsPaneHeaders" = false;
        "Workspace.sidebarCollapsed" = false;
        "Workspace.sidebarPosition" = "left";
        "Workspace.sidebarSwipe" = "optionSwipe";
        "Workspace.tabStyle" = "vertical";
        "Workspace.terminalCopyOnSelect" = false;
        "Workspace.terminalCursorStyle" = "block";
        # Cursor trail like kitty's cursor_trail / Neovide. Rex also ships:
        # warp, comet, blaze, blazeTapered, blazeNoTrail, ripple, sweep
        "Workspace.cursorShadersEnabled" = true;
        "Workspace.cursorShader" = "comet";
        "Workspace.terminalFontName" = "Maple Mono NF";
        "Workspace.terminalFontPointSize" = 14.0;
        # Thicker glyphs, like Ghostty's font-thicken / kitty's macOS rendering
        "Workspace.terminalFontSmoothing" = true;
        "Workspace.terminalPaddingColor" = "extend";
        "Workspace.terminalSelectionBackground" = "theme";
        "Workspace.terminalSelectionForeground" = "theme";
        "Workspace.terminalSelectionRoundedCorners" = true;
        "Workspace.terminalSmoothScrolling" = true;
        "Workspace.tintsPanesWithProgramBackground" = false;
        "Workspace.usesPaneGlass" = true;
        "Workspace.usesStandardInactiveWindowPaneStyles" = false;
      };
    };
}
