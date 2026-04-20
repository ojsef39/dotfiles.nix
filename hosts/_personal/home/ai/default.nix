{pkgs, ...}: let
  kubernetesMcpConfig = pkgs.writeText "kubernetes-mcp-server.toml" ''
    read_only = true

    [[denied_resources]]
    group = ""
    version = "v1"
    kind = "Secret"
  '';

  caBundle =
    if pkgs.stdenv.isDarwin
    then "/opt/homebrew/etc/ca-certificates/cert.pem"
    else "/etc/ssl/certs/ca-bundle.crt";

  # Workaround for anthropics/claude-code#32549: Claude Code deduplicates MCP servers
  # by command path only, so two servers with the same binary are collapsed into one.
  # Thin wrappers give each server a distinct store path.
  mkWrapper = name:
    pkgs.writeShellScriptBin "prometheus-mcp-server-${name}" ''
      exec ${pkgs.prometheus-mcp-server}/bin/prometheus-mcp-server "$@"
    '';
in {
  programs.mcp.servers = {
    "kubernetes-mcp-server" = {
      command = "${pkgs.kubernetes-mcp-server}/bin/kubernetes-mcp-server";
      args = ["--config" "${kubernetesMcpConfig}"];
    };
    "prometheus/talos-live-hla1" = {
      command = "${mkWrapper "talos-live-hla1"}/bin/prometheus-mcp-server-talos-live-hla1";
      args = [];
      env = {
        PROMETHEUS_URL = "https://thanos-query.live.k8.hla1.jhofer.lan";
        TOOL_PREFIX = "talos_live_hla1";
        REQUESTS_CA_BUNDLE = caBundle;
        SSL_CERT_FILE = caBundle;
      };
    };
    "prometheus/talos-dev-hla1" = {
      command = "${mkWrapper "talos-dev-hla1"}/bin/prometheus-mcp-server-talos-dev-hla1";
      args = [];
      env = {
        PROMETHEUS_URL = "https://thanos-query.dev.k8.hla1.jhofer.lan";
        TOOL_PREFIX = "talos_dev_hla1";
        REQUESTS_CA_BUNDLE = caBundle;
        SSL_CERT_FILE = caBundle;
      };
    };
  };
}
