_: {
  imports = [
    ./mcp.nix
    ./claude-code.nix
    ./copilot.nix
    ./opencode.nix
  ];

  _module.args.ai = {
    model = "claude-sonnet-4.6";
    effortLevel = "high";

    # Domains allowed across all AI tools
    # Used as WebFetch(domain:X) in claude-code, https://X in copilot
    allowedDomains = [
      "docs.github.com"
      "github.com"
      "home-manager.gitlab.io"
      "nix-community.github.io"
      "nix.dev"
      "nixos.org"
      "nixos.wiki"
      "patch-diff.githubusercontent.com"
      "raw.githubusercontent.com"
    ];
  };
}
