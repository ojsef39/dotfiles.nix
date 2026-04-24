{ai, ...}: {
  home.file = {
    ".copilot/instructions/dotfiles.nix".source = ai.instructionsDir;
    ".copilot/lsp-config.json".text = builtins.toJSON {
      lspServers = builtins.listToAttrs (map (s: {
          inherit (s) name;
          value = {
            inherit (s) command args;
            fileExtensions = s.languageIds;
          };
        })
        ai.lspServers);
    };
  };

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
