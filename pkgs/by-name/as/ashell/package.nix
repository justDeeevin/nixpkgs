{
  fetchFromGitHub,
  lib,
  rustPlatform,
  makeWrapper,
  pkg-config,
  libxkbcommon,
  libGL,
  pipewire,
  libpulseaudio,
  wayland,
  vulkan-loader,
  mesa,
}:
let
  libs = [
    libpulseaudio
    wayland
    mesa.drivers
    vulkan-loader
    libGL
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "ashell";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "MalpenZibo";
    repo = "ashell";
    rev = version;
    hash = "sha256-QZe67kjyHzJkZFoAOQhntYsHvvuM6L1y2wtGYTwizd4=";
  };
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "dnd-0.1.0" = "sha256-temNg+RdvquSLAdkwU5b6dtu9vZkXjnDASS/eJo2rz8=";
      "hyprland-0.4.0-beta.1-revision" = "sha256-of/nIfOy+a2ngsZlVXR/mEHopSbxGZN/6cOaushN5cA=";
      "iced_sctk-0.1.0" = "sha256-PnAnmM7PUWyp2p5KjpSIfY8874bucC11Y060jDImbjo=";
      "smithay-client-toolkit-0.18.0" = "sha256-/7twYMt5/LpzxLXAQKTGNnWcfspUkkZsN5hJu7KaANc=";
      "smithay-clipboard-0.8.0" = "sha256-MqzynFCZvzVg9/Ry/zrbH5R6//erlZV+nmQ2St63Wnc=";
    };
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    rustPlatform.bindgenHook
    libxkbcommon
    libGL
    pipewire
    libpulseaudio
    wayland
    vulkan-loader
  ];

  postFixup = ''
    wrapProgram $out/bin/ashell --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath libs}
  '';

  meta = {
    description = "A ready to go Wayland status bar for Hyprland";
    homepage = "https://github.com/MalpenZibo/ashell";
    license = lib.licenses.mit;
    mainProgram = "ashell";
    maintainers = with lib.maintainers; [ justdeeevin ];
    platforms = lib.platforms.linux;
  };
}
