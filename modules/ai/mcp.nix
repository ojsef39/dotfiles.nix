{
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    ...
  }: let
    # TODO: drop once nixpkgs-unstable has https://github.com/NixOS/nixpkgs/pull/578808 merged:
    # Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/2417
    # mcp v2 marks fastmcp-slim broken. Guarded since older nixpkgs has no mcp_1.
    # https://nixpkgs-tracker.ocfox.me/?pr=578808
    mcp-nixos =
      if pkgs.python3Packages ? mcp_1
      then
        pkgs.mcp-nixos.override {
          python3Packages = pkgs.python3Packages.overrideScope (final: _: {mcp = final.mcp_1;});
        }
      else pkgs.mcp-nixos;
  in {
    programs.mcp = {
      enable = true;
      servers = {
        "github-mcp-server" = {
          command = "${pkgs._1password-cli}/bin/op";
          args = ["run" "--" "${pkgs.github-mcp-server}/bin/github-mcp-server" "stdio" "--toolsets" "all" "--insiders"];
          env.GITHUB_PERSONAL_ACCESS_TOKEN = lib.mkDefault "op://Personal/GITHUB_TOKEN/mcp";
        };
        "nixos" = {
          command = "${mcp-nixos}/bin/mcp-nixos";
        };
        "io.github.upstash/context7" = {
          command = "${pkgs._1password-cli}/bin/op";
          args = ["run" "--" "${pkgs.context7-mcp}/bin/context7-mcp"];
          env.CONTEXT7_API_KEY = lib.mkDefault "op://Personal/Context7/api_key";
        };
        # NOTE: Only works if oAuth is supported
        "hass-hla1" = {
          url = "https://home-assistant.hla1.jhofer.org/api/mcp";
        };
      };
    };
  };
}
