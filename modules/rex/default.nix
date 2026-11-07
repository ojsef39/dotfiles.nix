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
    config,
    lib,
    pkgs,
    vars,
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

    mkRexTheme = {
      name,
      id,
      appearance,
      file,
    }: let
      themeFile = pkgs.fetchurl file;
      lines = lib.splitString "\n" (builtins.readFile themeFile);

      namedColor = key: let
        prefix = "${key} = ";
        line = lib.findFirst (line: lib.hasPrefix prefix line) (throw "${file.name}: no ${key}") lines;
      in
        toRexColor (lib.removePrefix "#" (lib.removePrefix prefix line));

      ansiPalette = let
        entries = map (line: {
          name = builtins.head (builtins.match "palette = ([0-9]+)=.*" line);
          value = toRexColor (lib.removePrefix "#" (builtins.elemAt (builtins.match "palette = [0-9]+=(.*)" line) 0));
        }) (lib.filter (line: lib.hasPrefix "palette = " line) lines);
        byIndex = lib.listToAttrs entries;
      in
        lib.genList (index: byIndex.${toString index}) 16;
    in {
      inherit id name appearance;
      palette = {
        ansi = ansiPalette;
        background = namedColor "background";
        foreground = namedColor "foreground";
        cursor = namedColor "cursor-color";
        cursorText = namedColor "cursor-text";
        selectionBackground = namedColor "selection-background";
        selectionForeground = namedColor "selection-foreground";
        paletteBase = {};
        paletteOverrides = {};
        paletteGenerate = false;
        paletteHarmonious = false;
      };
      source.ghosttyFile.fileName = file.name;
      createdAt = 0;
    };

    # Fixed ID so Workspace.darkThemeID / lightThemeID can point at it.
    # Macchiato for both appearances, like the Ghostty/kitty config.
    catppuccinMacchiato = mkRexTheme {
      name = "Catppuccin Macchiato";
      id = "custom-3E8D6F21-9A4C-4B7E-8D15-6C2F0A9B4E77";
      appearance = "dark";
      file = {
        name = "catppuccin-macchiato.conf";
        url = "https://raw.githubusercontent.com/catppuccin/ghostty/b0b03ccee7ae8f16b13bd4fdfe267616defdb2b7/themes/catppuccin-macchiato.conf";
        hash = "sha256-s8jPvV3IclD2naA8Ut9mcwyPAeaYPeBWlZk3EthsFCE=";
      };
    };

    rexThemeJSON = builtins.toJSON [catppuccinMacchiato];
  in
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      # Out-of-store symlink to the repo checkout, so the Lua config can be
      # edited and reloaded (ctrl+space r) without a rebuild.
      xdg.configFile."rex".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/${vars.git.ghq}/${vars.git.dotfiles}/modules/rex/config";

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

      # The themes cannot go through targets.darwin.defaults: Rex keeps imported
      # themes as JSON data, which a plist attrset cannot express. Writing the key
      # replaces any themes imported in the app.
      home.activation.rexTheme = lib.hm.dag.entryAfter ["writeBoundary" "setDarwinDefaults"] ''
        themeHex=$(printf '%s' ${lib.escapeShellArg rexThemeJSON} | ${pkgs.coreutils}/bin/od -An -v -tx1 | ${pkgs.coreutils}/bin/tr -d ' \n')
        run /usr/bin/defaults write com.superlogical.rex 'Workspace.customThemes' -data "$themeHex"
      '';

      # Rex stores its preferences as flat, dotted keys next to app state in one
      # domain. Only preferences are set here; `defaults import` merges.
      targets.darwin.defaults."com.superlogical.rex" = {
        RexAppUpdateAutomation = "install";

        "rex.agents.names-sessions" = true;
        # Needed for the experimental cursor shaders (Workspace.cursorShader)
        "rex.developer-mode-enabled" = true;
        # Needed by the project picker / scratch session to show new sessions
        "rex.client.remoteControl" = true;
        "rex.server.automatic-restart-enabled" = true;
        "rex.server.run-mode" = "bundled";

        "Workspace.activePaneBorderOpacity" = 0.5;
        "Workspace.activePaneBorderTransition" = "move";
        "Workspace.animationStyle" = "off";
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
        "Workspace.showsIdleProgramsInActivity" = false;
        "Workspace.showsPaneHeaders" = false;
        "Workspace.sidebarCollapsed" = false;
        "Workspace.sidebarPosition" = "left";
        "Workspace.sidebarSwipe" = "optionSwipe";
        # Workspace.tabStyle left unset: toggle with shift+cmd+s, Rex remembers it
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
