{config, ...}: let
  cfg = config.ai;
in {
  home.file = {
    ".copilot/instructions/dotfiles.nix".source = cfg.instructionsDir;
    ".copilot/lsp-config.json".text = builtins.toJSON {
      lspServers = builtins.listToAttrs (map (s: {
          inherit (s) name;
          value = {
            inherit (s) command args;
            fileExtensions = s.languageIds;
          };
        })
        cfg.lspServers);
    };
  };

  programs.github-copilot-cli = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      inherit (cfg) model effortLevel;
      allowed_urls = map (d: "https://${d}") cfg.allowedDomains;
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
