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
  pname = "sphinx-mdinclude";
  version = "0.5.1";
  format = "flit";

  src = fetchPypi {
    pname = "sphinx_mdinclude";
    inherit version;
    hash = "sha256-6f5UbUvoHrcqlDU2TWWBRSxmMj0zw9BxPxGzPhaZibg=";
  };

  patches = [
    # Not yet released: https://github.com/amyreese/sphinx-mdinclude/pull/9#issuecomment-1228255823
    (fetchpatch {
      url = "https://github.com/amyreese/sphinx-mdinclude/commit/3c2c1550d18351e32f11d0c5bd275f3b37667f06.patch";
      hash = "sha256-FDtWVJtz5qUZE5UJ4VFV/ElUwhAGnjjf6dR7HbSRI94=";
    })
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
