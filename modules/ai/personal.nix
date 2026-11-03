{
  flake.modules.homeManager.personal = {
    pkgs,
    lib,
    ...
  }: let
    caBundle =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "/opt/homebrew/etc/ca-certificates/cert.pem"
      else "/etc/ssl/certs/ca-bundle.crt";

    # Radar is an HTTP MCP server, so there is no process for op run to wrap and
    # no env in which to put a CA bundle. mcp-remote bridges it back to stdio,
    # which restores both.
    mkRadar = env: {
      command = "${pkgs._1password-cli}/bin/op";
      args = [
        "run"
        "--"
        "${pkgs.mcp-remote}/bin/mcp-remote"
        "https://kube-radar.${env}.k8.hla1.jhofer.lan/mcp"
        "--header"
        "Cookie:radar_session=\${RADAR_MCP_TOKEN}"
      ];
      env = {
        RADAR_MCP_TOKEN = lib.mkDefault "op://JHC/radar-mcp/token";
        NODE_EXTRA_CA_CERTS = caBundle;
      };
    };

    # Extends the Notifications section of instructions/default.instructions.md.
    awayInstructions = pkgs.writeTextDir "away.instructions.md" ''
      ---
      description: "Discord notifications while the user is away."
      applyTo: "**"
      ---

      ## Notifications while away

      - **If the user said they are going away**: run `send-away ~/.config/secrets/ai_discord_webhook "<message>"` instead of `send-cooking` to send a Discord notification.
        **Critical**: when the user is away, plan the entire task upfront using only pre-approved commands and tools (those in the allowlist) — never trigger anything that would require an approval prompt, since the user won't be there to approve it.
        If you can't complete the task without unapproved tools, say so before they leave.

      Message rules for `send-away`:

      - Markdown works (`**bold**`, code blocks, etc.) — Discord renders it.
      - Real newlines work — use actual newlines in the message, not literal `\n`.
      - Messages over 2000 chars are auto-truncated (Discord's hard limit).
      - No support for embeds / structured payloads — content only.
    '';
  in {
    home.packages = with pkgs; [
      archive-linear-issue
      jhcode
      send-away
    ];

    ai = {
      extraInstructionsDirs = [awayInstructions];
      allowedBashCommands = ["send-away *"];

      allowedMcpCalls = let
        radarReadTools = [
          "discover_metrics"
          "get_changes"
          "get_cluster_audit"
          "get_cluster_upgrade_readiness"
          "get_cost"
          "get_dashboard"
          "get_events"
          "get_helm_release"
          "get_neighborhood"
          "get_pod_logs"
          "get_prometheus_rules"
          "get_resource"
          "get_rightsizing"
          "get_runtime_versions"
          "get_subject_permissions"
          "get_topology"
          "get_workload_logs"
          "issues"
          "list_helm_releases"
          "list_namespaces"
          "list_packages"
          "list_resources"
          "query_prometheus"
          "search"
          "top_resources"
          "wait_for"
        ];
      in {
        "radar/talos-dev-hla1" = radarReadTools;
        "radar/talos-live-hla1" = radarReadTools;
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
    };

    programs.mcp.servers = {
      # NOTE: Only works if oAuth is supported
      "hass-hla1" = {
        url = "https://home-assistant.hla1.jhofer.org/api/mcp";
      };
      "radar/talos-dev-hla1" = mkRadar "dev";
      "radar/talos-live-hla1" = mkRadar "live";
    };
  };
}
