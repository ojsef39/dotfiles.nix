{
  pkgs,
  inputs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  programs.spicetify = {
    enable = true;

    # Theme: Catppuccin Macchiato
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "macchiato";

    # Extensions
    enabledExtensions = with spicePkgs.extensions; [
      betterGenres
      fullScreen
      hidePodcasts
      history
      keyboardShortcut
      songStats
      wikify
    ];

    # Custom Apps
    enabledCustomApps = with spicePkgs.apps; [
      lyricsPlus # Needed for full-screen
      marketplace # Just for browsing additional extensions/themes
      ncsVisualizer
    ];

    # Snippets
    enabledSnippets = with spicePkgs.snippets; [
      fixDjIcon
      fixedEpisodesIcon
      sonicDancing
    ];
  };
}
