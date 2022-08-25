{ lib
, buildPythonPackage
, fetchFromGitHub
, flask
, isPy27
, pytestCheckHook
, pythonAtLeast
, setuptools-scm
}:

buildPythonPackage rec {
  pname = "picobox";
  version = "2.2.0";

  # currently broken on 3.10 due to https://github.com/ikalnytskyi/picobox/issues/55
  disabled = isPy27 || pythonAtLeast "3.10";

  src = fetchFromGitHub {
    owner = "ikalnytskyi";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-B2A8GMhBFU/mb/JiiqtP+HvpPj5FYwaYO3gQN2QI6z0=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  nativeBuildInputs = [
    setuptools-scm
  ];


  checkInputs = [
    flask
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "picobox"
  ];

  meta = with lib; {
    description = "Opinionated dependency injection framework";
    homepage = "https://github.com/ikalnytskyi/picobox";
    license = licenses.mit;
    maintainers = with maintainers; [ flokli ];
  };
}
