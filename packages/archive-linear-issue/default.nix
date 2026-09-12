# Wrapper around github:ddikman/archive-linear-issue — bulk-archives Linear
# issues via the GraphQL API (Linear's free plan caps a workspace at 250).
#
# TESTING — smoke-test these on every change:
#   archive-linear-issue                     # usage error, no op prompt bypass
#   archive-linear-issue JHC-1               # token pulled from 1Password
#   LINEAR_API_KEY=lin_api_x archive-linear-issue JHC-1   # env wins, no op read
{pkgs}: let
  src = pkgs.fetchFromGitHub {
    owner = "ddikman";
    repo = "archive-linear-issue";
    rev = "2e76afdf696767bc0c3bdde91af0ec28bdcff3cb";
    hash = "sha256-d52MtXY92OwPq8Mkv3cCV/hv/NbaK2SCoaU5HiVe+tw=";
  };
in
  pkgs.writeShellApplication {
    name = "archive-linear-issue";
    runtimeInputs = with pkgs; [_1password-cli nodejs];
    text = ''
      # Fall back to 1Password when no key is in the environment. Failure is not
      # fatal: an explicit --api-key still works (upstream prefers the flag), and
      # op prints its own error to stderr.
      if [ -z "''${LINEAR_API_KEY:-}" ]; then
        LINEAR_API_KEY=$(op read "''${LINEAR_OP_REF:-op://JHC/LinearAPI/password}") || true
        export LINEAR_API_KEY
      fi

      exec node ${src}/bin/archive-linear-issue.js "$@"
    '';
  }
