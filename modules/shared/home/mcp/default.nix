{pkgs, ...}: {
  programs.mcp.servers = {
    context7 = {
      command = "${pkgs.context7-mcp}/bin/context7-mcp";
    };
  };
}
