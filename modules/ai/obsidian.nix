{
  flake.modules.homeManager.base = {
    config,
    lib,
    pkgs,
    vars,
    ...
  }: let
    cfg = config.ai;

    obsidianInstructions = pkgs.writeTextDir "obsidian.instructions.md" ''
      ---
      description: "Obsidian vault & runbook conventions."
      applyTo: "**"
      ---

      ## Obsidian

      Vault: `${toString cfg.obsidian.vaultPath}`
      Runbook folder (relative to vault): `${cfg.obsidian.runbookPath}`
      Full runbook path: `${toString cfg.obsidian.vaultPath}/${cfg.obsidian.runbookPath}`

      ### Tooling

      Prefer the `obsidian-cli` command for vault operations — it uses Obsidian's
      live index and respects templates. Run `obsidian-cli help` to see all
      subcommands.

      **Important**: do NOT call the bare `obsidian` command. It silently
      launches the GUI app instead of returning an error, which is misleading.
      Always use `obsidian-cli`.

      Use `obsidian-cli` for:
      - **Search**: `obsidian-cli search query="<text>"` (uses the live index,
        much better than `grep` on the vault).
      - **Backlinks / outgoing links**: `obsidian-cli backlinks`, `obsidian-cli links`.
      - **Tags / properties**: `obsidian-cli tags`, `obsidian-cli properties`,
        `obsidian-cli property:set`, `obsidian-cli property:read`.
      - **Creating files**: `obsidian-cli create path="..." content="..."` —
        pass `template=<name>` to instantiate from a vault template.

      `obsidian-cli` requires Obsidian to be running. If it errors because the
      app is closed, either:
      1. Launch the app with `obsidian >/dev/null 2>&1 & disown` (works on
         macOS and Linux; the redirect keeps GUI logs from spamming the
         terminal), wait a moment, then retry the CLI; or
      2. Fall back to direct Read/Write/Edit on the filesystem if the operation
         doesn't need indexed features (search, backlinks, templates).

      Only ever invoke `obsidian` in that exact redirected-and-disowned form.
      Never run it bare — it silently launches the GUI without erroring, which
      is misleading and easy to confuse with a successful CLI call.

      ### Runbook frontmatter conventions

      Runbooks may carry a list-type frontmatter property named `tickets`
      (depends on the template — not guaranteed to be present).

      When the current task is associated with a Linear or Jira issue (for
      example the user is working from an issue ID, or you discovered one via
      branch name / PR / commit message), append that issue ID to the
      `tickets` list. Use the canonical issue ID format (e.g. `ENG-1234`,
      `OPS-42`), not URLs.

      To update properties, prefer `obsidian-cli property:set name=tickets
      value="<id>" type=list` (verify with `obsidian-cli property:read` first
      so you don't clobber existing entries). If property:set is awkward for
      list appends, edit the YAML frontmatter directly — but keep the property
      name and list type intact.

      ### Writing runbooks

      When the user asks for a runbook, write it under the runbook folder above.

      ${
        if cfg.obsidian.runbookTemplate == null
        then ''
          No template is configured. Write a plain markdown file with sensible
          frontmatter and ask the user whether they'd like a template set up.
        ''
        else ''
          Configured template: `${cfg.obsidian.runbookTemplate}`. Instantiate via:

          ```
          obsidian-cli create path="${cfg.obsidian.runbookPath}/<name>.md" template="${cfg.obsidian.runbookTemplate}"
          ```

          If the CLI errors that the template is missing, fall back to writing
          a plain markdown file and tell the user the template is not present
          in their vault.
        ''
      }
    '';
  in {
    options.ai.obsidian = {
      vaultPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default =
          if pkgs.stdenv.isDarwin
          then "/Users/${vars.user.name}/Documents/Obsidian Vault"
          else null;
        description = "Absolute path to the Obsidian vault. null disables Obsidian instructions for AI tools.";
      };
      runbookPath = lib.mkOption {
        type = lib.types.str;
        default = "JHC/Runbooks";
        description = "Subfolder under vaultPath where runbooks live (relative path).";
      };
      runbookTemplate = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "JHC/Runbook";
        description = "Vault-relative template name (without .md) passed to `obsidian-cli create template=<name>`. Set to null to skip templating.";
      };
    };

    config.ai = {
      extraInstructionsDirs = lib.optional (cfg.obsidian.vaultPath != null) obsidianInstructions;

      allowedBashCommands = [
        "obsidian >/dev/null 2>&1 & disown"
        "obsidian-cli *"
      ];
    };
  };
}
