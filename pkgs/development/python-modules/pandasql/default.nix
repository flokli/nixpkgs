{
  lib,
  buildPythonPackage,
  fetchPypi,

  setuptools,

  numpy,
  pandas,
  sqlalchemy,

  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pandasql";
  version = "0.7.3";
  pyproject = true;

  # No tags on GitHub
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-HrJIhpCGQ1p9hSgevZ/lJdadnZVKDc64VPcajQ/Y3mk=";
  };

  postPatch = ''
    substituteInPlace pandasql/tests/test_pandasql.py \
      --replace-fail pandas.util.testing pandas.testing
  '';

  build-system = [ setuptools ];

  dependencies = [
    pandas
    numpy
    sqlalchemy
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # Tests are trying to load data over the network
  # doCheck = true;
  pythonImportsCheck = [ "pandasql" ];

  meta = with lib; {
    description = "sqldf for pandas";
    homepage = "https://github.com/yhat/pandasql";
    license = licenses.mit;
    maintainers = with maintainers; [ flokli ];
    platforms = platforms.unix;
  };
}
