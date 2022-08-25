{ lib
, buildPythonPackage
, deepmerge
, fetchFromGitHub
, isPy27
, setuptools-scm
, jsonschema
, picobox
, pyyaml
, sphinx_mdinclude
, sphinxcontrib_httpdomain
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-openapi";
  version = "unstable-2022-08-11";
  disabled = isPy27;

  # Switch to Cilums' fork of openapi, which uses m2r instead of mdinclude,
  # as m2r is unmaintained and incompatible with the version of mistune.
  # See
  # https://github.com/cilium/cilium/commit/b9862461568dd41d4dc8924711d4cc363907270b and
  # https://github.com/cilium/openapi/commit/cd829a05caebd90b31e325d4c9c2714b459d135f
  # for details.
  src = fetchFromGitHub {
    owner = "cilium";
    repo = "openapi";
    rev = "a1d4fca2e7c3ae3cca69593baade1ebc297a12ff";
    sha256 = "sha256-4xW4Qgr7IR055B74M/zn9cdnTmC4Pg7QZB3mH4YjDk4=";
  };

  patches = [
    ./stop-using-collections-abc.patch
  ];

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [
    deepmerge
    jsonschema
    picobox
    pyyaml
    sphinx_mdinclude
    sphinxcontrib_httpdomain
  ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/ikalnytskyi/sphinxcontrib-openapi";
    description = "OpenAPI (fka Swagger) spec renderer for Sphinx";
    license = licenses.bsd0;
  };

}
