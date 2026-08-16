# An aggregate name only exists if some file writes to it. These are imported by
# ../wiring and ../hosts unconditionally, so they need to survive going empty —
# delete `homeManager.nixos` below and wiring/nixos.nix fails with
# `attribute 'nixos' missing`.
#
# Add a name here only if something imports it and it may be empty. Host names
# and optional capabilities (`nixos.nvidia`) need no entry: the files writing to
# them create them, and nothing imports them unless a host asks.
#
# Audience is encoded in the name:
#   base        - reusable, the public surface a downstream flake imports
#   personal    - only for own machines, never exported
#   <hostname>  - only for that one machine
#   <optional>  - an opt-in capability, e.g. `nvidia`
#
# List aggregates: `just aggregates`
# Find every file contributing to one: `just where <name>`
_: {
  flake.modules = {
    generic = {
      base = {};
      personal = {};
    };

    darwin = {
      base = {};
    };

    nixos = {
      base = {};
    };

    homeManager = {
      base = {};
      darwin = {};
      nixos = {};
      personal = {};
    };
  };
}
