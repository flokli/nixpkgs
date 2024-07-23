{ mkDerivation
, extra-cmake-modules
, kguiaddons
, kidletime
, kwayland
, kwindowsystem
, qtbase
, wayland-scanner
, wayland
, wayland-protocols
}:

mkDerivation {
  pname = "layer-shell-qt";
  nativeBuildInputs = [ extra-cmake-modules wayland.bin ];
  buildInputs = [ kguiaddons kidletime kwindowsystem kwayland qtbase wayland-scanner wayland wayland-protocols ];
}
