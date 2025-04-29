{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  jupyter-packaging,
  jupyterlab,
  setuptools,

  # dependencies
  numpy,
  bqplot,
  traittypes,
  requests,
  ipython_genutils,
  ipyvue,
  ipyvuetify,
  ipywebrtc,
  ipywidgets,
  pythreejs,
  matplotlib,
  traitlets,

  # tests
  pytestCheckHook,
  scipy,

}:

buildPythonPackage rec {
  pname = "ipyvolume";
  version = "0.6.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "widgetti";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-nmBtD+GfY72yubWOs7eq2iC/dtvHLopAuF7eYKic5aY=";
  };

  build-system = [
    jupyter-packaging
    jupyterlab
    setuptools
  ];

  # It seems pythonRelaxDeps doesn't work for these
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "jupyter_packaging~=" "jupyter_packaging>=" \
      --replace-fail "jupyterlab~=" "jupyterlab>="
  '';

  dependencies = [
    bqplot
    ipython_genutils
    ipyvue
    ipyvuetify
    ipywebrtc
    ipywidgets
    matplotlib
    numpy
    pythreejs
    requests
    traitlets
    traittypes
  ];

  nativeCheckInputs = [
    pytestCheckHook
    scipy
  ];

  pythonImportsCheck = [ "ipyvolume" ];

  pytestFlagsArray = [
    # Fails even with bokeh provided
    "--deselect=ipyvolume/test_all.py::test_bokeh"

    # Require networking
    "--deselect=ipyvolume/test_all.py::test_download"
    "--deselect=ipyvolume/test_all.py::test_example_head"
    "--deselect=ipyvolume/test_all.py::test_datasets"

    # Gets confused about location of index.js
    "--deselect=ipyvolume/test_all.py::test_embed"
  ];

  meta = {
    description = "3d plotting for Python in the Jupyter notebook based on IPython widgets using WebGL";
    homepage = "https://github.com/widgetti/ipyvolume";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
