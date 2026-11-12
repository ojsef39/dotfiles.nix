---
description: "User preferences that apply in every repo."
applyTo: "**"
---

## Keeping knowledge

Auto memory is off. Everything worth keeping goes into reviewed files instead:

- A fix, gotcha or procedure for a component: a runbook (see the Obsidian runbook rules). Update an existing runbook before creating a new one.
- A rule for how to work in a repo: that repo's CLAUDE.md. A rule for every repo: the global instructions (see "Managing these instructions").

Propose the edit when it comes up (after a fix is verified, or when the user corrects you), don't wait to be asked. Write it as plain technical content: no quotes of the user, no story of the session. The user reviews it in git.

## Shell snippets

The user's interactive shell is fish. Commands the user runs themselves must be fish syntax:

- `for x in a b; ...; end`, `if test ...; ...; end`, `(cmd)` for substitution
- No `FOO=bar cmd` prefix: use `env FOO=bar cmd` or `set -x FOO bar`
- No heredocs: pipe a multi-line single-quoted string, or write a file and pass its path

Your own Bash tool calls and `#!/usr/bin/env bash` scripts are unaffected.

## Writing

- No em dashes in prose, docs, comments or commit messages. Use a comma, colon, period or parentheses, or restructure.
- Plain, direct, DRY. No repeating a point, no bolded buzzword intros, no polished-but-hollow phrasing.

## Secrets

Never touch secrets yourself. Don't read secret stores or files holding credentials (not even key names), don't dump objects that may carry them (K8s Secrets, pod specs, operator CRs), and don't run commands that output them. When a task needs any of that, give the user the command to run instead.

## Comments and commit messages

- Default to no comments. If the lines you edit had none, don't add one.
- A comment is only for a non-obvious WHY that outlives the conversation, or a real TODO. Max 2 lines, also in new files.
- One TODO per follow-up task: extend the existing TODO instead of adding a second one for the same removal or upgrade.
- Never put chat content in files or commits: what we're trying, why something was not changed, rationale that only makes sense with the conversation. That goes in chat; metric-based rationale for a value change goes in the commit body.
- Commit messages: technical, 1-3 lines or a few bullets, what the commit does. No stories.

## Debugging

- Don't anchor on the first plausible cause. Treat each new measurement as a test of the theory, and re-plan when it contradicts it.
- Report what the evidence rules out, not only what it points to.
- Read the component's own error output early instead of inferring cause from charts.
- Cross-check derived metrics against ground truth before quoting magnitudes (`increase()` over long windows extrapolates).
- When the user says "it's not X", treat that as a real prior.

## Standards

- Never use "it's a homelab" to justify a shortcut (security, robustness, performance, env-specific config). The infra is run like a datacenter: if a production setup would do it, do it.
- Tools for the cluster: research open-source options first. Closed single-maintainer binaries are a last resort, paid services for rarely used features are out.
- "Verified locally" for a CI step means running the workflow's exact `run:` command with CI's env, no extra local flags, after first reproducing the CI failure.
- Before waiting on cluster state, check that the condition you wait for can actually fire. Short timeouts, check real state between steps; `sleep` only for time-based waits.

## Linear

- One state comment per ticket, edited in place (`list_comments`, then `save_comment` with `id`). New comments only for separate records like research results.
- Plans, next steps and future work go in the Linear ticket.
- No "Pre-reqs" / "Out of scope" / "Related: JHC-X" sections in descriptions; Linear relations cover that. External links (PRs, docs) are fine.
- Bare `#1234` autolinks to JHOFER-Cloud/fleet. Write other repos' issues and PRs as full links: `[owner#1234](https://github.com/owner/repo/pull/1234)`.
- The team has both `Canceled` (`7ed48b1e-9b29-4652-a8eb-3c2c54b7ed30`) and `Duplicate` (`84aac15f-1235-4c53-afd6-d01b83821c58`) as canceled-type statuses, and name matching picks Duplicate. Set cancel states by ID.

## Working with the user

- Hands-on walkthroughs (commands the user runs, checks, test plans): one step per reply, wait for its output before the next.
- Don't paste diffs into chat for review. Name the changed files and the intent; the user reviews in lazygit.
- Several open PRs at once: before switching to another PR, check that CodeRabbit finished reviewing the latest push on all of them and say which ones it is still on. Wait 1-2 minutes after its check goes green.
- Every round of PR feedback, read all three sources before fixing anything: inline review threads, every review body (outside-diff-range and additional comments live only there) and the PR conversation comments (CodeRabbit sometimes posts findings only there). Even when the user points at one comment, list every open finding against the current HEAD, then fix all still-valid ones in one pass.

## Xcode / Expo iOS builds

The shell puts nix's clang-wrapper first on PATH and sets `LD`, `CC`, `CXX`, `SDKROOT`, `DEVELOPER_DIR` to a nix apple-sdk, so `xcodebuild` / `expo run:ios` fail at link time (`ld: -objc_abi_version '-Xlinker' not supported`, rsync errors in `[CP] Copy XCFrameworks`).

Run builds and Metro under `env -i HOME=... PATH=/usr/bin:/bin:/usr/sbin:/sbin:<bun>/bin:<cocoapods>/bin:/etc/profiles/per-user/josefhofer/bin`, with bun/cocoapods from `nix build --no-link --print-out-paths nixpkgs#bun` (rebuild if GC'd). Use `env -u DEVELOPER_DIR` for `xcode-select -p`. Xcode 27's Simulator is `DeviceHub.app` under `/Applications/Xcode.app/Contents/Applications/`. Restart Metro with `--clear` after branch switches.
