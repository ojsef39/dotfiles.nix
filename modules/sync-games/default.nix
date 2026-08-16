{
  flake.modules.nixos.josef-nd1-gpu0 = {pkgs, ...}: {
    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "sync-games";

        runtimeInputs = with pkgs; [
          rsync
          cifs-utils
          _1password-cli
          coreutils
          util-linux # for mountpoint
          gnugrep
          gawk
        ];

        text = builtins.readFile ./sync-games.sh;
      })
    ];
  };
}
