{
  pkgs,
  lib,
  ...
}: {
  programs.mcp = {
    enable = true;
    servers = {
      "github-mcp-server" = {
        command = "${pkgs._1password-cli}/bin/op";
        args = ["run" "--" "${pkgs.github-mcp-server}/bin/github-mcp-server" "stdio" "--toolsets" "all" "--insiders"];
        env.GITHUB_PERSONAL_ACCESS_TOKEN = lib.mkDefault "op://Personal/GITHUB_TOKEN/mcp";
      };
      "io.github.upstash/context7" = {
        command = "${pkgs._1password-cli}/bin/op";
        args = ["run" "--" "${pkgs.context7-mcp}/bin/context7-mcp"];
        env.CONTEXT7_API_KEY = lib.mkDefault "op://Personal/Context7/api_key";
      };
    };
  };
}
