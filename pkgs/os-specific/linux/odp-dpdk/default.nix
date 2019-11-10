{ stdenv, fetchurl, autoreconfHook, pkgconfig
, dpdk, libconfig, libpcap, numactl, openssl, zlib, libbsd, libelf, jansson
}: let
  dpdk_18_11 = dpdk.overrideAttrs (old: rec {
    version = "18.11.3";
    src = fetchurl {
      url = "https://fast.dpdk.org/rel/dpdk-${version}.tar.xz";
      sha256 = "1cdnxpa3chhv43ing6c28a5xhs9g848wdfc2vqlrs3ww6yad09g5";
    };
  });

in stdenv.mkDerivation rec {
  pname = "odp-dpdk";
  version = "1.22.0.0_DPDK_18.11";

  src = fetchurl {
    url = "https://git.linaro.org/lng/odp-dpdk.git/snapshot/${pname}-${version}.tar.gz";
    sha256 = "1m8xhmfjqlj2gkkigq5ka3yh0xgzrcpfpaxp1pnh8d1g99094vbx";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ dpdk_18_11 libconfig libpcap numactl openssl zlib libbsd libelf jansson ];

  #dontDisableStatic = true;

  #NIX_LDFLAGS = "-latomic";

  meta = with stdenv.lib; {
    description = "Open Data Plane optimized for DPDK";
    homepage = https://www.opendataplane.org;
    license = licenses.bsd3;
    platforms =  [ "x86_64-linux" ];
    maintainers = [ maintainers.abuibrahim ];
  };
}
