{ lib, python3Packages, fetchFromGitHub, cloud-utils }:

let version = "19.4";

in python3Packages.buildPythonApplication {
  pname = "cloud-init";
  inherit version;
  namePrefix = "";

  src = fetchFromGitHub {
    owner = "canonical";
    repo = "cloud-init";
    rev = version;
    sha256 = "0nd5v4xd8f1lmd0ivhrrxk8yj35z7sclpxv9qxbkyw6jl10328pz";
  };

  patches = [ ./add-nixos-support.patch ];

  prePatch = ''
    patchShebangs ./tools

    substituteInPlace setup.py \
      --replace /usr $out \
      --replace /etc $out/etc \
      --replace /lib/systemd $out/lib/systemd \
      --replace 'self.init_system = ""' 'self.init_system = "systemd"'

    substituteInPlace cloudinit/config/cc_growpart.py \
      --replace 'util.subp(["growpart"' 'util.subp(["${cloud-utils}/bin/growpart"'
    '';

  propagatedBuildInputs = with python3Packages; [
    jinja2
    oauthlib
    pyserial
    configobj
    pyyaml
    requests
    jsonpatch
    jsonschema
    six
  ];

  checkInputs = with python3Packages; [ contextlib2 httpretty mock unittest2 ];
  doCheck = false;

  meta = {
    homepage = "https://cloudinit.readthedocs.org";
    description = "Provides configuration and customization of cloud instance";
    maintainers = [ lib.maintainers.madjar lib.maintainers.phile314 ];
    platforms = lib.platforms.all;
  };
}
