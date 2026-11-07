{
  flake.modules.homeManager.base = {
    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "macchiato";
      # Default background instead of #24273a, so Rex's pane glass shows through
      k9s.transparent = true;
    };
  };
}
