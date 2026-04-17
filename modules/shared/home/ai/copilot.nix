{ ai, ... }: {
  programs.github-copilot-cli = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      inherit (ai) model effortLevel;
      theme = "auto";
      banner = "never";
      renderMarkdown = true;
      autoUpdate = false; # managed by nix
      includeCoAuthoredBy = true;
      respectGitignore = true;
      allowed_urls = map (d: "https://${d}") ai.allowedDomains;
    };
  };
}
