{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, expat
, zlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ipu6-camera-bins";
  version = "unstable-2023-08-10";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "ipu6-camera-bins";
    rev = "c4f9e5245ac2c7b29b39d95f14e96138b8380789";
    hash = "sha256-I+11f4AbuGnYmS8ItIaUdogXgQS4Rs7Is2zWq3BtMGM=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    stdenv.cc.cc.lib
    expat
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp --no-preserve=mode --recursive \
      lib \
      include \
      $out/

    install -m 0644 -D LICENSE $out/share/doc/LICENSE

    runHook postInstall
  '';

  postFixup = ''
    for pcfile in $out/lib/*/pkgconfig/*.pc; do
      substituteInPlace $pcfile \
        --replace 'prefix=/usr' "prefix=$out"
    done
  '';

  meta = with lib; {
    description = "IPU firmware and proprietary image processing libraries";
    homepage = "https://github.com/intel/ipu6-camera-bins";
    license = licenses.issl;
    sourceProvenance = with sourceTypes; [
      binaryFirmware
    ];
    maintainers = with maintainers; [
      hexa
    ];
    platforms = [ "x86_64-linux" ];
  };
})
