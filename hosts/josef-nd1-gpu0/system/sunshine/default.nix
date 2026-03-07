{
  config,
  pkgs,
  vars,
  lib,
  ...
}: let
  hostname = config.networking.hostName;
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
        while True:
            with pipe_path.open(encoding='utf-8') as pipe:
                subprocess.Popen(['/run/current-system/sw/bin/steam', pipe.read().strip()], env=steam_env)
    finally:
        pipe_path.unlink(missing_ok=True)
  '';

  # TODO: move `sunshine-virt-display` to nixkit
  # Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/508
  sunshine-virt-display = pkgs.stdenv.mkDerivation {
    pname = "sunshine-virt-display";
    version = "unstable-2026-03-06";

    src = pkgs.fetchFromGitHub {
      owner = "frostplexx";
      repo = "sunshine_virt_display";
      rev = "5fa8c763fab3e0bdbcc433f8897a7a842fdc15d5";
      sha256 = "17sjk8f4xhdgmsanr3pkb865v60v042lwsdwh5ghrigzdiddgbcv";
    };

    nativeBuildInputs = [pkgs.makeWrapper];
    buildInputs = [
      pkgs.python3
      pkgs.bash
    ];

    installPhase = ''
      mkdir -p $out/bin

      cp -r * $out/bin/
      chmod +x $out/bin/virt_display.sh

      wrapProgram $out/bin/virt_display.sh \
        --prefix PATH : ${
        lib.makeBinPath [
          pkgs.python3
          pkgs.bash
          pkgs.coreutils
        ]
      } \
        --suffix PATH : /run/wrappers/bin
    '';

    meta = {
      description = "Virtual display manager for Sunshine streaming";
      homepage = "https://github.com/frostplexx/sunshine_virt_display";
      license = lib.licenses.mit;
    };
  };
in {
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # required for KMS screen capture
    openFirewall = true;
    package = pkgs.sunshine.override {cudaSupport = true;};

    settings = {
      sunshine_name = hostname;
      port = 48100;
    };

    applications = {
      apps = [
        {
          name = "Desktop";
          image-path = "desktop.png";
        }
        {
          name = "Virtual Desktop";
          image-path = "${./virtual_desktop.png}";
          prep-cmd = [
            {
              do = ''sh -c "${sunshine-virt-display}/bin/virt_display.sh --connect --width ''${SUNSHINE_CLIENT_WIDTH} --height ''${SUNSHINE_CLIENT_HEIGHT} --refresh-rate ''${SUNSHINE_CLIENT_FPS}"'';
              undo = "${sunshine-virt-display}/bin/virt_display.sh --disconnect";
            }
          ];
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

  systemd.user.services = {
    steam-run-url-service = {
      enable = true;
      description = "Listen and starts steam games by id";
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

  # Enable debugfs for virtual display management (required by sunshine_virt_display)
  boot.kernelModules = ["debugfs"];

  # Configure sudoers for passwordless execution of the virtual display script
  security.sudo.extraRules = [
    {
      users = [vars.user.name];
      commands = [
        {
          command = "${pkgs.python3}/bin/python3 ${sunshine-virt-display}/bin/main.py *";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
