{ stdenv, lib
, kernel
, fetchurl
, pkgconfig, meson, ninja, cmake
, libbsd, numactl, libbpf, zlib, libelf, jansson, openssl, libpcap
, doxygen, python3
, shared ? false }:

let
  kver = kernel.modDirVersion or null;
  mod = kernel != null;

in stdenv.mkDerivation rec {
  name = "dpdk-${version}" + lib.optionalString mod "-${kernel.version}";
  version = "19.08";

  src = fetchurl {
    url = "https://fast.dpdk.org/rel/dpdk-${version}.tar.xz";
    sha256 = "0xgrkip2aji1c7jy5gk38zzwlp5ap1s6dmbcag5dnyy3bmwvmp9y";
  };

  nativeBuildInputs = [ pkgconfig meson ninja cmake doxygen python3.pkgs.sphinx python3 ];
  buildInputs = [ numactl libbsd libbpf zlib libelf jansson openssl.dev libpcap ] ++ lib.optional mod kernel.moduleBuildDependencies;

  postPatch = ''
    patchShebangs config/arm
  '';

  mesonFlags = [
    "-Denable_docs=true"
    "-Denable_kmods=${if kernel != null then "true" else "false"}"
    "-Ddefault_library=${if shared == true then "shared" else "static"}"
  ]
  ++ lib.optional stdenv.isx86_64 "-Dmachine=nehalem"
  ++ lib.optional (kernel != null) "-Dkernel_dir=${kernel.dev}/lib/modules/${kernel.modDirVersion}";

  outputs = [ "out" ] ++ lib.optional mod "kmod";

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Set of libraries and drivers for fast packet processing";
    homepage = http://dpdk.org/;
    license = with licenses; [ lgpl21 gpl2 bsd2 ];
    platforms =  [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ domenkozar magenbluten orivej ];
  };
}
