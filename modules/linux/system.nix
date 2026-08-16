{
  flake.modules.nixos.base = _: {
    # SSH daemon
    services.openssh.enable = true;
  };
}
