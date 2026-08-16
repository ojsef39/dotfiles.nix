{
  flake.modules.homeManager.base =
    # Temporary workaround — delete this file when zen-browser-flake PR #212 is merged
    # and the zen-browser flake input is updated to the version that includes the fix.
    # PR: https://github.com/0xc000022070/zen-browser-flake/pull/212
    #
    # Root cause: package.nix's installPhase calls `/usr/bin/codesign --force --sign -`
    # which replaces Zen's original Apple Developer signature with ad-hoc (no Team ID).
    # 1Password requires a valid Team ID → rejects the app.
    # Fix: skip that codesign call AND dontFixup to prevent fixupPhase from re-signing too.
    {
      pkgs,
      lib,
      inputs,
      config,
      ...
    }: {
      # Apply policies via macOS preferences plist — wrapFirefox is bypassed on Darwin so
      # policies.json is never written. config.programs.zen-browser.policies reads the value
      # defined in default.nix so there's no duplication. Remove when PR #212 merges
      # (hm-module will handle targets.darwin.defaults automatically after that).
      targets.darwin.defaults = lib.mkIf pkgs.stdenv.isDarwin {
        "app.zen-browser.zen" =
          {EnterprisePoliciesEnabled = true;}
          // config.programs.zen-browser.policies;
      };

      programs.zen-browser.package = lib.mkIf pkgs.stdenv.isDarwin (
        pkgs.lib.makeOverridable
        (
          _:
            inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta-unwrapped.overrideAttrs (old: {
              installPhase = builtins.replaceStrings ["/usr/bin/codesign"] [": "] old.installPhase;
              dontFixup = true;
            })
        ) {}
      );
    };
}
