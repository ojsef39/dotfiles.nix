{
  flake.modules.homeManager.personal = {pkgs, ...}: let
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
    ai.allowedMcpCalls = {
      "kubernetes-mcp-server" = [
        "configuration_contexts_list"
        "configuration_view"
        "events_list"
        "namespaces_list"
        "nodes_log"
        "nodes_stats_summary"
        "nodes_top"
        "pods_get"
        "pods_list"
        "pods_list_in_namespace"
        "pods_log"
        "pods_top"
        "resources_get"
        "resources_list"
      ];
      "prometheus/talos-dev-hla1" = [
        "talos_dev_hla1_execute_query"
        "talos_dev_hla1_execute_range_query"
        "talos_dev_hla1_get_metric_metadata"
        "talos_dev_hla1_get_targets"
        "talos_dev_hla1_health_check"
        "talos_dev_hla1_list_metrics"
      ];
      "prometheus/talos-live-hla1" = [
        "talos_live_hla1_execute_query"
        "talos_live_hla1_execute_range_query"
        "talos_live_hla1_get_metric_metadata"
        "talos_live_hla1_get_targets"
        "talos_live_hla1_health_check"
        "talos_live_hla1_list_metrics"
      ];
      "claude.ai/Linear" = [
        "extract_images"
        "get_attachment"
        "get_diff"
        "get_diff_threads"
        "get_document"
        "get_initiative"
        "get_issue"
        "get_issue_status"
        "get_milestone"
        "get_project"
        "get_status_updates"
        "get_team"
        "get_user"
        "list_comments"
        "list_cycles"
        "list_diffs"
        "list_documents"
        "list_initiatives"
        "list_issue_labels"
        "list_issue_statuses"
        "list_issues"
        "list_milestones"
        "list_project_labels"
        "list_projects"
        "list_teams"
        "list_users"
        "search_documentation"
      ];
    };

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
  };
}
