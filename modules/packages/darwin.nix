{
  flake.modules.darwin.base = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # CLI utilities
      # _1password-cli  # Password manager
      container
      mist-cli

      # GUI Applications
      mist
      obsidian # Note-taking
      stats
    ];
  };

  flake.modules.darwin.personal = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      aichat
      utm # Virtualization
      whatcable
    ];
  };
}
