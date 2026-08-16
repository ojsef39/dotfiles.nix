# Declares every module aggregate this flake publishes, so each name always
# exists even when no feature file currently contributes to it. Without this a
# temporarily-empty aggregate becomes an `attribute ... missing` error at the
# point of use rather than a no-op.
#
# Audience is encoded in the name:
#   base      - reusable, part of the public surface a downstream flake imports
#   personal  - only for own machines, never exported
#   <host>    - only for that one machine
_: {
  flake.modules = {
    generic.base = {};
    generic.personal = {};

    darwin.base = {};
    darwin.mac = {};

    nixos.base = {};
    nixos.josef-nd1-gpu0 = {};

    homeManager.base = {};
    homeManager.darwin = {};
    homeManager.nixos = {};
    homeManager.personal = {};
    homeManager.josef-nd1-gpu0 = {};
  };
}
