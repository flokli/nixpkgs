{ stdenv, fetchurl, lib, autoPatchelfHook, fixDarwinDylibNames, ... }:
let
  pname = "ada_language_server";
  version = "22.0.2";

  srcFilename = {
    "x86_64-linux" = "linux-${version}.tar.gz";
    "x86_64-darwin" = "darwin-${version}.tar.gz";
  }."${stdenv.targetPlatform.system}";
  sha256 = {
    "x86_64-linux" = "0in5wp20kc66y0xh9ndyz7fpq6qsyy7zgdpdzh9q3ikggb8aqv62";
    "x86_64-darwin" = "0kmz07pgfjm3pxv8j8j5qf29nj0a6a03rpxhrbw08msbzywd91np";
  }."${stdenv.targetPlatform.system}";

  extLib = stdenv.hostPlatform.extensions.sharedLibrary;
in
stdenv.mkDerivation {
  inherit pname version;
  src = fetchurl {
    url = "https://dl.bintray.com/reznikmm/ada-language-server/${srcFilename}";
    inherit sha256;
  };

  nativeBuildInputs = lib.optional stdenv.isLinux autoPatchelfHook
    ++ lib.optional stdenv.isDarwin fixDarwinDylibNames;
  buildInputs = [ stdenv.cc.cc.lib ];

  doBuild = false;

  installPhase = ''
    install -Dm755 ada_language_server "$out/bin/ada_language_server"
    install -Dm644 -t $out/lib *${extLib}*
  '';

  meta = {
    description = "Server implementing the Microsoft Language Protocol for Ada and SPARK";
    homepage = https://github.com/AdaCore/ada_language_server;
    license = lib.licenses.gpl3;
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
  };
}
