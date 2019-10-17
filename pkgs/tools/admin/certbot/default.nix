{ stdenv, python37Packages, fetchFromGitHub, fetchurl, dialog, autoPatchelfHook, nginx }:

let
  pebble_linux_amd64 = stdenv.mkDerivation rec {
    name = "pebble";
    version = "2.2.1";
    src = fetchurl {
      url = "https://github.com/letsencrypt/pebble/releases/download/v${version}/pebble_linux-amd64";
      sha256 = "0frw0125px79sfqplaqx5dcfchwvm3il63p56qr2843j1amc1lxf";
    };

    nativeBuildInputs = [ autoPatchelfHook ];

    phases = [ "installPhase" "fixupPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      install -m0755 ${src} $out/bin/pebble_linux_amd64
    '';
  };
in python37Packages.buildPythonApplication rec {
  pname = "certbot";
  version = "0.39.0";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "1s32xg2ljz7ci78wc8rqkjvgrz7vprb7fkznrlf9a4blm55pp54c";
  };

  patches = [
    ./0001-pebble_artifacts-hardcode-pebble-location.patch
  ];

  propagatedBuildInputs = with python37Packages; [
    ConfigArgParse
    acme
    configobj
    cryptography
    distro
    josepy
    parsedatetime
    psutil
    pyRFC3339
    pyopenssl
    pytz
    six
    zope_component
    zope_interface
  ];

  buildInputs = [ dialog ] ++ (with python37Packages; [ mock gnureadline ]);

  checkInputs = with python37Packages; [
    pytest_xdist
    pytest
    dateutil
  ];

  postPatch = ''
    substituteInPlace certbot/notify.py --replace "/usr/sbin/sendmail" "/run/wrappers/bin/sendmail"
    substituteInPlace certbot/util.py --replace "sw_vers" "/usr/bin/sw_vers"
    substituteInPlace certbot-ci/certbot_integration_tests/utils/pebble_artifacts.py --replace "@pebble@" "${pebble_linux_amd64}/bin/pebble_linux_amd64"
  '';

  postInstall = ''
    for i in $out/bin/*; do
      wrapProgram "$i" --prefix PYTHONPATH : "$PYTHONPATH" \
                       --prefix PATH : "${dialog}/bin:$PATH"
    done
  '';

  # tests currently time out, because they're trying to do network access
  # Upstream issue: https://github.com/certbot/certbot/issues/7450
  doCheck = false

  checkPhase = ''
    PATH="$out/bin:${nginx}/bin:$PATH" pytest certbot-ci/certbot_integration_tests
  '';

  dontUseSetuptoolsCheck = true;

  meta = with stdenv.lib; {
    homepage = src.meta.homepage;
    description = "ACME client that can obtain certs and extensibly update server configurations";
    platforms = platforms.unix;
    maintainers = [ maintainers.domenkozar ];
    license = licenses.asl20;
  };
}
