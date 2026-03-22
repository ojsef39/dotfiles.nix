{
  config,
  pkgs,
  vars,
  ...
}: let
  steam-run-url = pkgs.writeShellApplication {
    name = "steam-run-url";
    text = ''
      echo "$1" > "/run/user/$(id --user)/steam-run-url.fifo"
    '';
    runtimeInputs = [pkgs.coreutils];
  };

  #FIX: https://github.com/NixOS/nixpkgs/issues/463989
  # https://discourse.nixos.org/t/sunshine-self-hosted-game-stream/25608/33
  # labels: upstream, bug, os:nix
  steam-run-url-service-script = pkgs.writeText "steam-run-url-service.py" ''
    import os
    from pathlib import Path
    import subprocess

    pipe_path = Path(f'/run/user/{os.getuid()}/steam-run-url.fifo')
    try:
        pipe_path.parent.mkdir(parents=True, exist_ok=True)
        pipe_path.unlink(missing_ok=True)
        os.mkfifo(pipe_path, 0o600)
        steam_env = os.environ.copy()
        steam_env["QT_QPA_PLATFORM"] = "wayland"
        procs = []
        while True:
            procs = [p for p in procs if p.poll() is None]
            with pipe_path.open(encoding='utf-8') as pipe:
                url = pipe.read().strip()
                if url:
                    proc = subprocess.Popen(
                        ['/run/current-system/sw/bin/steam', url],
                        env=steam_env,
                    )
                    procs.append(proc)
    finally:
        pipe_path.unlink(missing_ok=True)
  '';
in {
  services = {
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # required for KMS screen capture
      openFirewall = true;
      package = pkgs.sunshine.override {cudaSupport = true;};

      settings = {
        sunshine_name = config.networking.hostName;
        port = 48100;
      };

      applications = {
        apps = [
          {
            name = "Desktop";
            image-path = "desktop.png";
          }
          {
            name = "Steam Big Picture";
            image-path = "steam.png";
            detached = ["${steam-run-url}/bin/steam-run-url steam://open/bigpicture"];
            prep-cmd = [
              {
                do = "";
                undo = "${steam-run-url}/bin/steam-run-url steam://close/bigpicture";
              }
            ];
            exclude-global-prep-cmd = "false";
            auto-detach = "true";
          }
        ];
      };
    };

    sunshine-virt-display = {
      enable = true;
      user = vars.user.name;
    };
  };

  systemd.user.services = {
    steam-run-url-service = {
      enable = true;
      description = "Listens for steam:// URLs and starts Steam games";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig.Restart = "on-failure";
      script = "${pkgs.python3}/bin/python3 ${steam-run-url-service-script}";
    };
    sunshine.path = [steam-run-url];
  };

  # Fix permissions for uinput device, required for mouse/keyboard input
  hardware.uinput.enable = true;
  users.users.${vars.user.name}.extraGroups = ["uinput"];
}
