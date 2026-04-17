{ai, ...}: {
  programs.github-copilot-cli = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      inherit (ai) model effortLevel;
      allowed_urls = map (d: "https://${d}") ai.allowedDomains;
      autoUpdate = false; # managed by nix
      banner = "never";
      experimental = true;
      includeCoAuthoredBy = true;
      renderMarkdown = true;
      respectGitignore = true;
      theme = "auto";
    };
  };
}
