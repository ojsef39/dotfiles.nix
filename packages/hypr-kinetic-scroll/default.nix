# Wrapper around github:savonovv/hypr-kinetic-scroll — compositor-level
# kinetic (inertial) touchpad scrolling for Hyprland. ABI-tied to the
# Hyprland build it's compiled against, so this must track pkgs.hyprland.
{
  stdenv,
  pkg-config,
  hyprland,
  hyprutils,
  hyprlang,
  aquamarine,
  hyprcursor,
  hyprgraphics,
  libGL,
  pixman,
  libdrm,
  cairo,
  pango,
  libinput,
  udev,
  wayland,
  libxkbcommon,
  libxcb,
  libxcb-wm,
  libxcb-errors,
  lua5_5,
  inputs,
}:
stdenv.mkDerivation {
  pname = "hypr-kinetic-scroll";
  version = "0-unstable-2026-07-28";

  src = inputs.hypr-kinetic-scroll;

  nativeBuildInputs = [pkg-config];
  buildInputs = [
    hyprland
    hyprutils
    hyprlang
    aquamarine
    hyprcursor
    hyprgraphics
    libGL
    pixman
    libdrm
    cairo
    pango
    libinput
    udev
    wayland
    libxkbcommon
    libxcb
    libxcb-wm
    libxcb-errors
    lua5_5
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 hypr-kinetic-scroll.so $out/lib/libhypr-kinetic-scroll.so
    runHook postInstall
  '';
}
