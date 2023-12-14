{ fetchFromGitHub
, findutils
, gnugrep
, gnused
, iproute2
, iptables
, lib
, nettools
, openssh
, openssl
, parted
, procps
, python39
, shadow
, util-linux
}:

let
  inherit (lib) makeBinPath;
  # the latest python version that waagent test against according to https://github.com/Azure/WALinuxAgent/blob/28345a55f9b21dae89472111635fd6e41809d958/.github/workflows/ci_pr.yml#L75
  python = python39;

in
python.pkgs.buildPythonApplication rec {
  pname = "waagent";
  version = "2.8.0.11";
  src = fetchFromGitHub {
    owner = "Azure";
    repo = "WALinuxAgent";
    rev = "04ded9f0b708cfaf4f9b68eead1aef4cc4f32eeb";
    sha256 = "0fvjanvsz1zyzhbjr2alq5fnld43mdd776r2qid5jy5glzv0xbhf";
  };
  patches = [
    # Suppress the following error when waagent tries to configure sshd:
    # Read-only file system: '/etc/ssh/sshd_config'
    ./dont-configure-sshd.patch

    ./udev-set-mode-with-MODE.patch
  ];
  doCheck = false;

  propagatedBuildInputs = [ python.pkgs.distro ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      findutils
      gnugrep
      gnused
      iproute2
      iptables
      nettools # for hostname
      openssh
      openssl
      parted
      procps # for pidof
      shadow # for useradd, usermod
      util-linux # for (u)mount, fdisk, sfdisk, mkswap
    ])
  ];

  # The binary entrypoint and udev rules are placed to the wrong place.
  # Move them to their default location.
  preFixup = ''
    mv $out/${python.sitePackages}/usr/sbin $out/bin
    rm $out/bin/waagent2.0
    rmdir $out/${python.sitePackages}/usr

    mv $out/${python.sitePackages}/etc $out/
  '';

  meta = {
    description = "The Microsoft Azure Linux Agent (waagent)";
    longDescription = ''
      The Microsoft Azure Linux Agent (waagent)
      manages Linux provisioning and VM interaction with the Azure
      Fabric Controller'';
    homepage = "https://github.com/Azure/WALinuxAgent";
    license = with lib.licenses; [ asl20 ];
  };
}
