{ stdenv
, fetchpatch
, fetchFromGitHub
, bash
, bison
, boehmgc
, boost
, cmake
, doxygen
, flex
, gmp
, graphviz
, gtest
, libpcap
, llvm
, pkgconfig
, protobuf
, python2
, python3
}:

stdenv.mkDerivation rec {
  pname = "p4c";
  version = "unstable-2020-04-04";

  src = fetchFromGitHub {
    owner = "p4lang";
    repo = "p4c";
    rev = "15e0865d2ac15df2ac89a23eade31695bfa49723";
    sha256 = "1gd3dhgdbs2h5h9zzmndlkv20h9khffkgfs7i6zpiarrys4b9r9a";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    bison
    cmake
    doxygen
    flex
    graphviz
    llvm
    pkgconfig
    protobuf
    python3
  ];
  buildInputs = [
    boehmgc
    boost.dev
    gmp
    gtest
  ];

  cmakeFlags = [
    "-DENABLE_DOCS=ON"
  ];

  outputs = [ "out" "doc" ];

  doCheck = true;

  postPatch = let
    # the run-{e,u}bpf-test.py scripts import ply and scapy
    testPythonEnv = python3.withPackages (ps: [ ps.scapy ps.ply ]);
  in ''
    patchShebangs tools/testutils.py tools/stf/stf_test.py tools/driver/p4c.in \
      testdata/p4_16_samples/gen-large.py control-plane/p4runtime/tools/madokolint.py\
      backends/p4test/run-p4-sample.py backends/ebpf/targets/*.py backends/bmv2/bmv2stf.py

    # tools/cpplint.py still needs python2
    sed -i "s|/usr/bin/env python2|${python2}/bin/python|" tools/cpplint.py
    sed -i "s|/bin/bash|${bash}/bin/bash|" cmake/P4CUtils.cmake

    # provide custom python env for run-{e,u}bpf-test.py
    sed -i "s|/usr/bin/env python3|${testPythonEnv}/bin/python3|" \
      backends/ebpf/run-ebpf-test.py backends/ubpf/run-ubpf-test.py

    # add missing pcap libdir and includedir to ebpf runtime Makefile
    sed -i 's|LIBS+=-lpcap|LIBS+=-lpcap -L${libpcap}/lib|' backends/ebpf/runtime/runtime.mk
    sed -i 's|override INCLUDES+= -I$(dir $(BPFOBJ))|override INCLUDES+= -I$(dir $(BPFOBJ)) -I${libpcap}/include|' backends/ebpf/runtime/runtime.mk

    # … and the same for the ubpf runtime Makefile
    sed -i 's|LIBS+=-lpcap|LIBS+=-lpcap -L${libpcap}/lib|' backends/ubpf/runtime/runtime.mk
    sed -i 's|override INCLUDES+= -I$(dir $(BPFOBJ))|override INCLUDES+= -I$(dir $(BPFOBJ)) -I${libpcap}/include|' backends/ubpf/runtime/runtime.mk
  '';

  # move docs to a more appropriate location
  postInstall = ''
    mkdir -p $out/share/doc
    mv $out/share/p4c/docs $out/share/doc/p4c
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/p4lang/p4c";
    description = "P4_16 prototype compiler ";
    platforms = stdenv.lib.platforms.unix;
    license = stdenv.lib.licenses.asl20;
    maintainers = with maintainers; [ flokli ];
  };
}
