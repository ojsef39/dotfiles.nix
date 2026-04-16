{pkgs, ...}: {
  programs.mcp = {
    enable = true;
    servers = {
      context7 = {
        command = "${pkgs._1password-cli}/bin/op";
        args = ["run" "--" "${pkgs.context7-mcp}/bin/context7-mcp"];
        env.CONTEXT7_API_KEY = "op://Personal/Context7/api_key";
      };
    };
  };
}
