{
  lib,
  fetchurl,
  fetchFromGitHub,
  writeText,
  cmake,
  cudaPackages_12_0,
  curl,
  pkg-config,
  xsimd,
  zlib,
}:

let
  cudaPackages = cudaPackages_12_0;
  stdenv = cudaPackages.backendStdenv;
  rapidsCmake = stdenv.mkDerivation {
    name = "rapids-cmake";
    src = fetchFromGitHub {
      owner = "rapidsai";
      repo = "rapids-cmake";
      # branch-25.10
      rev = "7aa8fd4e8ef8d36196be4186dd39a20c2eadd028";
      hash = "sha256-eJDENogBh0ADefYGbmrPqVI1AcDgodIfhsVtICrTY/M=";
    };
    patches = [
      # helps with debugging, optional
      ./rapids-cmake-log-output_file.patch
    ];
    installPhase = ''
      mkdir -p $out
      cp -R . $out/
    '';
  };
  cpm = fetchurl {
    # CPM_DOWNLOAD_VERSION in rapids-cmake/cpm/detail/download.cmake
    url = "https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.0/CPM.cmake";
    hash = "sha256-ezVPOll2xGJsh2hQyTlE5SyD7FmhWa5d5b55g/Dheio=";
  };

  # assemble a toplevel CMakeLists.txt, which calls FetchContent_Declare with all sources,
  # pointing to nix store paths.
  # This together with CPM_USE_LOCAL_PACKAGES=ON in cmakeFlags causes CPM to use find_package(),
  # which will use the sources from our FetchContent_Declare calls,
  # rather than downloading from the internet.
  rootCMakeLists = writeText "CMakeLists.txt" (
    ''
      cmake_minimum_required(VERSION 3.30.4 FATAL_ERROR)
      include(FetchContent)
    ''
    +
      lib.strings.concatMapAttrsStringSep "\n"
        (k: v: "FetchContent_Declare(${k} SOURCE_DIR ${v} FIND_PACKAGE_ARGS NAMES ${k})")
        {
          # cudf repo deps:
          dlpack = fetchFromGitHub {
            owner = "dmlc";
            repo = "dlpack";
            # v0.8 tag, as per cpp/cmake/thirdparty/get_dlpack.cmake
            rev = "365b823cedb281cd0240ca601aba9b78771f91a3";
            hash = "sha256-IcfCoz3PfDdRetikc2MZM1sJFOyRgKonWMk21HPbrso=";
          };
          jitify = fetchFromGitHub {
            owner = "rapidsai";
            repo = "jitify";
            # jitify2 branch, as per cpp/cmake/thirdparty/get_dlpack.cmake
            rev = "e38b993f4cb3207745735c51d4f61cdaa735b7ac";
            hash = "sha256-QgnZJ8J1zg19jPoWardHSN+aCvTadUXMdPcwWovbuTY=";
          };
          flatbuffers = fetchFromGitHub {
            owner = "google";
            repo = "flatbuffers";
            # v24.3.25 tag, as per cpp/cmake/thirdparty/get_flatbuffers.cmake
            rev = "595bf0007ab1929570c7671f091313c8fc20644e"; # ?
            hash = "sha256-uE9CQnhzVgOweYLhWPn2hvzXHyBbFiFVESJ1AEM3BmA=";
          };
          kvikio = fetchFromGitHub {
            owner = "rapidsai";
            repo = "kvikio";
            # branch-${CUDF_VERSION_MAJOR}.${CUDF_VERSION_MINOR}, as per cpp/cmake/thirdparty/get_kvikio.cmake
            rev = "c9935d144f56e5b2d2c3557db0417ce2c1e9207c";
            hash = "sha256-oxuWn5ZzE4kLTQ555JnUR2DidfPOuuMt0kuEVkpg1Yk=";
          };
          # as per cpp/cmake/thirdparty/get_nanoarrow.cmake
          nanoarrow = fetchFromGitHub {
            owner = "apache";
            repo = "arrow-nanoarrow";
            rev = "4bf5a9322626e95e3717e43de7616c0a256179eb";
            hash = "sha256-VtpnkBNWumZI7mHnJtXSHv4ajIPQxrkBErnaAAq6pTY=";
          };
          Arrow = fetchFromGitHub {
            owner = "apache";
            repo = "arrow";
            # apache-arrow-${VERSION} tag, with version from CUDF_VERSION_Arrow,
            # in cpp/cmake/thirdparty/get_arrow.cmake
            rev = "a999eaccb12378f9e4e9ab758f18edc25b0991e5";
            hash = "sha256-rjU/D362QfmejzjIsYaEwTMcLADbNf/pQohb323ifZI=";
          };

          # rapids-cmake, see rapids-cmake/cpm/versions.json
          benchmark = fetchFromGitHub {
            owner = "google";
            repo = "benchmark";
            rev = "2dd015dfef425c866d9a43f2c67d8b52d709acb6";
            hash = "sha256-pUW9YVaujs/y00/SiPqDgK4wvVsaM7QUp/65k0t7Yr0=";
          };
          cuco = fetchFromGitHub {
            owner = "NVIDIA";
            repo = "cuCollections";
            rev = "6d0c28e855545a7b89df1c4276b2e7fef351682c";
            hash = "sha256-S9pH6D6EM88Sz0Zgp9siG/CTOpmlQhdoh1cVyszF4kY=";
          };
          GTest = fetchFromGitHub {
            owner = "google";
            repo = "googletest";
            rev = "6910c9d9165801d8827d628cb72eb7ea9dd538c5";
            hash = "sha256-01PK9LxqHno89gypd7ze5gDP4V3en2J5g6JZRqohDB0=";
          };
          rapids_logger = fetchFromGitHub {
            owner = "rapidsai";
            repo = "rapids-logger";
            rev = "46070bb255482f0782ca840ae45de9354380e298";
            hash = "sha256-/K5/j/1czaOs5G06Gpd+I+3OTDAa6Z+6tS0VW1+yEcI=";
          };
          spdlog = fetchFromGitHub {
            owner = "gabime";
            repo = "spdlog";
            rev = "27cb4c76708608465c413f6d0e6b8d99a4d84302";
            hash = "sha256-F7khXbMilbh5b+eKnzcB0fPPWQqUHqAYPWJb83OnUKQ=";
          };
          nvcomp = fetchFromGitHub {
            owner = "NVIDIA";
            repo = "nvcomp";
            rev = "a6e4e64a177e07cd2e5c8c5e07bb66ffefceae84";
            hash = "sha256-8UQPbQTHGDRJkdkga0npBxvA5fI5YTt0PhteXx0iAz4=";
          };
          nvtx3 = fetchFromGitHub {
            owner = "NVIDIA";
            repo = "NVTX";
            rev = "69c9949150ac1c310758a304082228a36d5e4758";
            hash = "sha256-uB1HHLVoOO0rWOcOqfypdiveagnjDcQQZNP7xBHhCwE=";
          };
          CCCL = fetchFromGitHub {
            owner = "NVIDIA";
            repo = "cccl";
            rev = "a1c47643a941eb3b13128f96afd4a050e824acf2";
            hash = "sha256-YD9KTvBEukfSB27ytIeE2GbgcULxLEo3r+FDYOi9EVw=";
          };
          rmm = fetchFromGitHub {
            owner = "rapidsai";
            repo = "rmm";
            # follows the same branch as rapidsai/rapids-cmake, branch-25.10 in our case
            rev = "e1d777a5e3dd1306970432a35d0f868ccf67f523";
            hash = "sha256-aDis8qXyDFDb02MHNnfMhflmh4rD+L7N4rzuEe7HZ6I=";
          };
          bs_thread_pool = fetchFromGitHub {
            owner = "bshoshany";
            repo = "thread-pool";
            rev = "097aa718f25d44315cadb80b407144ad455ee4f9";
            hash = "sha256-zhRFEmPYNFLqQCfvdAaG5VBNle9Qm8FepIIIrT9sh88=";
          };
        }
    + "\nadd_subdirectory(cpp)"
  );

in

stdenv.mkDerivation rec {
  pname = "libcudf";
  version = "25.06.00";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rapidsai";
    repo = "cudf";
    tag = "v${version}";
    hash = "sha256-5Z3NkHuLmFOoZTdyNK04kSvsfz/JkJHyVWZh+umQCYU=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  # TODO: figure out how to pass in cpm without this
  dontUseCmakeBuildDir = true;

  postPatch = ''
    install -D ${cpm} /build/source/cmake/CPM_0.40.0.cmake
    cp ${rootCMakeLists} CMakeLists.txt
  '';

  cmakeFlags = [
    # don't download rapids-cmake
    "-Drapids-cmake-url=${rapidsCmake}"

    # Tell CPM to pick up packages via find_package.
    (lib.cmakeBool "CPM_USE_LOCAL_PACKAGES" true)

    # TODO: check if we need this, it requires different kind of patching
    (lib.cmakeBool "CUDF_USE_PROPRIETARY_NVCOMP" false)

    "-DCUB_DIR=${lib.getDev cudaPackages.cuda_cccl.dev}/include"

    # "--trace-expand"
  ];

  nativeBuildInputs = [
    cmake
    cudaPackages.setupCudaHook
    cudaPackages.cuda_nvcc
    pkg-config
  ];

  buildInputs = [
    # kvikio wants libcurl
    curl

    xsimd

    cudaPackages.cuda_cudart # cuda_runtime.h
    cudaPackages.cuda_nvrtc # nvrtc.h
    zlib
  ];

  # TODO: look at jitify, the custom commands in there try to dlopen libnvrtc.so.12.0,
  # which doesn't exist. Figure out where this comes from and patch it.
  # Adding `export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${cudaPackages.cuda_nvrtc.lib}/lib`
  # to the build did not help.
  # Two ore hacks
  patches = [ ./wat.patch ];

  # TODO: look at CUDA_ARCHITECTURES. Does it do some probing at build time?

  meta = {
    description = "GPU DataFrame Library";
    homepage = "https://docs.rapids.ai/api/cudf/stable";
    changelog = "https://github.com/rapidsai/cudf/releases/tag/v${version}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
