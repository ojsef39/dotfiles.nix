{
  config,
  pkgs,
  vars,
  lib,
  ...
}: let
  hostname = config.networking.hostName;

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
    buildInputs = [pkgs.python3 pkgs.bash];

    installPhase = ''
      mkdir -p $out/bin

      cp -r * $out/bin/
      chmod +x $out/bin/virt_display.sh

      wrapProgram $out/bin/virt_display.sh \
        --prefix PATH : ${lib.makeBinPath [pkgs.python3 pkgs.bash pkgs.coreutils]} \
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
          output = "steam steam://open/bigpicture";
          cmd = "setsid steam steam://open/bigpicture";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
      ];
    };
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
