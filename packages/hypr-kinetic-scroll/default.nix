# Wrapper around github:savonovv/hypr-kinetic-scroll — compositor-level
# kinetic (inertial) touchpad scrolling for Hyprland. ABI-tied to the
# Hyprland build it's compiled against, so this must track pkgs.hyprland.
{
  lib,
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

  # Hyprland 0.57 moved CWindow::m_class to metadata().appID().
  # TODO: drop once upstream builds against 0.57
  postPatch = lib.optionalString (lib.versionAtLeast hyprland.version "0.57") ''
    substituteInPlace kinetic.cpp --replace-fail 'PWIN->m_class' 'PWIN->metadata().appID()'
    sed -i '1a #include <hyprland/src/desktop/view/window/WindowMetadata.hpp>' kinetic.cpp
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 hypr-kinetic-scroll.so $out/lib/libhypr-kinetic-scroll.so
    runHook postInstall
  '';
}
