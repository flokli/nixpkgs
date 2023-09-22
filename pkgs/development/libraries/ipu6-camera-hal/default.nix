{ lib
, stdenv
, fetchFromGitHub

# build
, cmake
, pkg-config

# runtime
, expat
, ipu6-camera-bins
, libtool
, gst_all_1
, ipuVersion ? "ipu6"
}:

let
  prefix =
    if ipuVersion == "ipu6" then "ipu_tgl"
    else if ipuVersion == "ipu6ep" then "ipu_adl"
    else if ipuVersion == "ipu6epmtl" then "ipu_mtl"
    else throw "Invalid IPU version";
in
stdenv.mkDerivation {
  pname = "${ipuVersion}-camera-hal";
  version = "unstable-2023-09-07";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "ipu6-camera-hal";
    rev = "93642d2f137c11aa77c9f8b656199fbcc08edfbd";
    hash = "sha256-IxRu11yMFmX5d4hG/fAoVea6B6jGmx27hDJvP3ou3ng=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  cmakeFlags = [
    "-DIPU_VER=${ipuVersion}"
    "-DUSE_PG_LITE_PIPE=ON"

    "-DLIBGCSS_FOUND=ON"
    "-DLIBGCSS_INCLUDE_DIRS=${ipu6-camera-bins}/include/${prefix}/ia_camera"
    "-DIA_IMAGING_FOUND=ON"
    "-DIA_IMAGING_LIBRARY_DIRS=${ipu6-camera-bins}/lib/${prefix}"
    "-DIA_IMAGING_INCLUDE_DIRS=${ipu6-camera-bins}/include/${prefix}/ia_imaging"
    "-DLIBIPU_FOUND=ON"
    "-DLIBIPU_LIBRARY_DIRS=${ipu6-camera-bins}/lib/${prefix}"
    "-DLIBIPU_INCLUDE_DIRS=${ipu6-camera-bins}/include/${prefix}"
  ];

  enableParallelBuilding = true;

  buildInputs = [
    expat
    ipu6-camera-bins
    libtool
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
  ];

  postPatch = ''
    substituteInPlace src/platformdata/PlatformData.h \
      --replace '/usr/share/' "${placeholder "out"}/share/"
  '';

  passthru = {
    inherit ipuVersion;
  };

  meta = with lib; {
    description = "HAL for processing of images in userspace";
    homepage = "https://github.com/intel/ipu6-camera-hal";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
    platforms = [ "x86_64-linux" ];
  };
}
