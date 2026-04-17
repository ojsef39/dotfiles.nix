{
  pkgs,
  lib,
  ...
}: {
  programs.mcp = {
    enable = true;
    servers = {
      "io.github.upstash/context7" = {
        command = "${pkgs._1password-cli}/bin/op";
        args = ["run" "--" "${pkgs.context7-mcp}/bin/context7-mcp"];
        env.CONTEXT7_API_KEY = lib.mkDefault "op://Personal/Context7/api_key";
      };
    };
  };
}
