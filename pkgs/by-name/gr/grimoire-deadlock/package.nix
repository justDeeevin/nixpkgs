{
  lib,
  stdenv,
  fetchFromGitHub,
  applyPatches,
  fetchPnpmDeps,
  makeDesktopItem,
  pnpm,
  pnpmConfigHook,
  nodejs,
  python3,
  electron_39,
}:
let
  electron = electron_39;
in
stdenv.mkDerivation (finalAttrs: {
  _structuredAttrs = true;

  pname = "grimoire-deadlock";
  version = "1.7.0";
  src = applyPatches {
    src = fetchFromGitHub {
      owner = "Slush97";
      repo = "grimoire";
      tag = "v${finalAttrs.version}";
      hash = "sha256-9bNJrkkNqTbMBHpYAcujjaCfqgY+eDLAPb2qcMlXzYs=";
    };
    patches = [ ./update-electron.patch ];
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm
    nodejs
    python3
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-WtfNj1B9ZKRvzlpEQK4YjEqRgc5r4jMtBqVkGJZSJPk=";
  };

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    npm_config_nodedir = electron.headers;
    npm_config_runtime = "electron";
    npm_config_target = electron.version;
  };

  buildPhase = ''
    runHook preBuild

    pnpm exec electron-rebuild -f -w better-sqlite3

    pnpm exec electron-vite build
    pnpm exec electron-builder --dir --linux \
      --config.electronDist="${electron}/libexec/electron" \
      --config.electronVersion="${electron.version}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 $src/resources/icon.ico $out/share/icons/hicolor/256x256/apps/Grimoire.ico

    mkdir -p $out/share/grimoire

    cp -r release/linux-unpacked/* $out/share/grimoire

    mkdir -p $out/bin

    ln -s $out/share/grimoire/grimoire $out/bin/grimoire

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    name = "grimoire";
    desktopName = "Grimoire";
    comment = "Mod manager for Deadlock";
    exec = "grimoire";
    icon = "Grimoire";
    terminal = false;
    keywords = [
      "Deadlock"
      "Mods"
      "Modding"
      "Mod Manager"
      "Game"
      "Valve"
    ];
    # TODO: startupWMClass
  };

  meta = with lib; {
    description = "Mod manager for Deadlock";
    homepage = "https://github.com/Slush97/grimoire";
    license = licenses.mit;
    mainProgram = "grimoire";
    maintainers = with maintainers; [ justdeeevin ];
    platforms = platforms.linux;
  };
})
