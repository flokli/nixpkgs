{
  lib,
  fetchFromGitHub,
  meson,
  ninja,
  gtk4,
  wrapGAppsHook4,
  gobject-introspection,
  glib,
  python3,
  python3Packages,
  desktop-file-utils,
  libadwaita,
  gst_all_1,
}:

# TODO: add gnome extension
# TODO: do something about result/share/breezydesktop/breezydesktop.gresource,
# needs to be copied to ~/.local/share/breezydesktop currently

python3Packages.buildPythonApplication rec {
  pname = "breezy-desktop";
  version = "2.1.1-beta";

  src = fetchFromGitHub {
    owner = "wheaney";
    repo = "breezy-desktop";
    tag = "v${version}";
    hash = "sha256-BF2NJbWDN4ujlC8WjOU+Gi6YLWPnzbdIrrG6ZmtgKl4=";
    fetchSubmodules = true;
  };

  format = "other";

  sourceRoot = "${src.name}/ui";

  nativeBuildInputs = [
    meson
    ninja
    wrapGAppsHook4
    python3
    desktop-file-utils # update-desktop-database
    gobject-introspection
  ];

  buildInputs =
    [
      gtk4
      glib
      libadwaita
    ]
    ++ (with gst_all_1; [
      gstreamer
      gst-plugins-base
      gst-plugins-bad
      gst-plugins-good
    ]);

  dependencies = [ python3Packages.pygobject3 ];

  postInstall = ''
    cp ../src/breezydesktop.gresource.xml $out/share/breezydesktop/

    # HACK: meson.build is missing some sources
    cp ../src/virtualdisplayrow.py $out/share/breezydesktop/breezydesktop/
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix PYTHONPATH : "${placeholder "out"}/share/breezydesktop")
    gappsWrapperArgs+=(--prefix GI_TYPELIB_PATH : "${glib.out}/lib/girepository-1.0")
  '';

  meta = with lib; {
    homepage = "https://github.com/wheaney/breezy-desktop";
    description = " XR virtual workspace library for Linux ";
    maintainers = [ maintainers.flokli ];
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
