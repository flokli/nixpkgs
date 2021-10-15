{ lib
, stdenv
, fetchFromGitHub
, coreutils
, findutils
, git
, gnugrep
, gnused
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "helm-git";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "aslafy-z";
    repo = pname;
    rev = "v${version}";
    sha256 = "0hvycqibmlw2zw3nm8rn73v5x1zcgm2jrfdlljbvc1n4n5vnzdrg";
  };

  nativeBuildInputs = [ makeWrapper ];

  # NOTE: helm-git is comprised of shell scripts.
  dontBuild = true;

  installPhase = ''
    install -dm755 $out/${pname}
    install -m644 -Dt $out/${pname} plugin.yaml
    cp helm-git helm-git-plugin.sh $out/${pname}/

    patchShebangs $out/${pname}/helm-git{,-plugin.sh}
    wrapProgram $out/${pname}/helm-git \
        --prefix PATH : ${lib.makeBinPath [ coreutils findutils git gnugrep gnused ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "The Helm downloader plugin that provides GIT protocol support";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ flokli ];
  };
}
