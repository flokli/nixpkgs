{
  alsa-lib,
  dbus,
  fetchFromGitHub,
  fontconfig,
  lib,
  libGL,
  libX11,
  libXext,
  libXrandr,
  libxkbcommon,
  makeWrapper,
  nix-update-script,
  openvr,
  openxr-loader,
  pipewire,
  pkg-config,
  pulseaudio,
  rustPlatform,
  shaderc,
  stdenv,
  testers,
  wayland,
  wlx-overlay-s,
  withOpenVr ? true,
}:

rustPlatform.buildRustPackage rec {
  pname = "wlx-overlay-s";
  version = "25.4.2";

  src = fetchFromGitHub {
    owner = "flokli";
    repo = "wlx-overlay-s";
    rev = "b1cb055870c36a213ad61bce457b3a7655ec7a9e";
    hash = "sha256-nU4PhBP7hJOpHg7rINU374xp4975LAeFQZO3XqFTTyQ=";
  };

  # cargoHash = "sha256-Mgie4cvFotr7I/pOJJWaUHF/vQYBg2WUeV//b1vv2nw=";
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    allowBuiltinFetchGit = true;
  };

  # explicitly only add openvr if withOpenVr is set to true.
  buildNoDefaultFeatures = true;
  buildFeatures = [
    "openxr"
    "osc"
    "x11"
    "wayland"
    "wayvr"
  ]
  ++ lib.optional withOpenVr "openvr";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    alsa-lib
    dbus
    fontconfig
    libGL
    libX11
    libXext
    libXrandr
    libxkbcommon
    openxr-loader
    pipewire
    wayland
  ]
  ++ lib.optional withOpenVr openvr;

  env.SHADERC_LIB_DIR = "${lib.getLib shaderc}/lib";

  postPatch = ''
    substituteAllInPlace src/res/watch.yaml \
      --replace '"pactl"' '"${lib.getExe' pulseaudio "pactl"}"'

    # TODO: src/res/keyboard.yaml references 'whisper_stt'
  '';

  passthru = {
    tests.testVersion = testers.testVersion { package = wlx-overlay-s; };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Wayland/X11 desktop overlay for SteamVR and OpenXR, Vulkan edition";
    homepage = "https://github.com/galister/wlx-overlay-s";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Scrumplex ];
    platforms = lib.platforms.linux;
    mainProgram = "wlx-overlay-s";
  };
}
