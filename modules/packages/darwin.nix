{
  flake.modules.darwin.base = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # CLI utilities
      # _1password-cli  # Password manager
      aichat
      container
      mist-cli

      # GUI Applications
      mist
      obsidian # Note-taking
      stats
      utm # Virtualization
      whatcable
    ];
  };
}
