{ lib
, buildPythonPackage
, fetchpatch
, fetchPypi
, flit-core
, docutils
, mistune
, pygments
}:

buildPythonPackage rec {
  pname = "sphinx_mdinclude";
  version = "0.5.1";
  format = "flit";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6f5UbUvoHrcqlDU2TWWBRSxmMj0zw9BxPxGzPhaZibg=";
  };

  patches = [
    ./docutils-0.19-compat.patch
  ];

  nativeBuildInputs = [ flit-core ];
  propagatedBuildInputs = [ mistune docutils ];

  checkInputs = [ pygments ];

  meta = with lib; {
    homepage = "https://github.com/miyakogi/m2r";
    description = "Sphinx extension for including or writing pages in Markdown format.";
    longDescription = ''
      A simple Sphinx extension that enables including Markdown documents from within
      reStructuredText.
      It provides the .. mdinclude:: directive, and automatically converts the content of
      Markdown documents to reStructuredText format.

      sphinx-mdinclude is a fork of m2r and m2r2, focused only on providing a Sphinx extension.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ flokli ];
  };
}
