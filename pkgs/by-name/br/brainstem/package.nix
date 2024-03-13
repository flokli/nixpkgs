{ stdenv
, lib
, autoPatchelfHook
, fetchurl
, systemd
, writeText
, ...
}:

let
  version = "2.10.5";
  # Upstream has a udev.sh script asking for mode and group, but with uaccess we
  # don't need any of that and can make it entirely static.
  udevRule = writeText "99-brainstem.rules" ''
    # Acroname Brainstem control devices
    SUBSYSTEM=="usb",ATTRS{idVendor}=="24ff", TAG+="uaccess"

    # Acroname recovery devices (pb82, pb242, pb167)
    SUBSYSTEM=="tty",ATTRS{idVendor}=="0424",ATTRS{idProduct}=="274e", TAG+="uaccess"
    SUBSYSTEM=="tty",ATTRS{idVendor}=="10c4",ATTRS{idProduct}=="ea60", TAG+="uaccess"
    KERNEL=="hidraw*",ATTRS{idVendor}=="1fc9",ATTRS{idProduct}=="0130", TAG+="uaccess"
  '';
in

stdenv.mkDerivation {
  pname = "brainstem";
  inherit version;

  src = fetchurl {
    url = "https://acroname.com/sites/default/files/software/brainstem_sdk/${version}/brainstem_sdk_${version}_Ubuntu_LTS_22.04_x86_64.tgz";
    hash = "sha256-w6bz2izhvhXDM8UwdfHsqD1QNss/KzDFV/ZiqtVN0Xg=";
  };

  # There's no "brainstem" parent directory in the archive
  unpackCmd = ''
    mkdir out
    tar xf $curSrc -C out
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m744 cli/AcronameHubCLI $out/bin

    mkdir -p $out/lib/udev/rules.d
    cp ${udevRule} $out/lib/udev/rules.d/99-brainstem.rules
  '';

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    # libudev
    (lib.getLib systemd)
    # libstdc++.so libgcc_s.so
    stdenv.cc.cc.lib
  ];

  meta = with lib; {
    description = "BrainStem Software Development Kit";
    homepage = "https://acroname.com";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    mainProgram = "AcronameHubCLI";
  };
}
