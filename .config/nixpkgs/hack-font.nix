{ buildPythonPackage 
, fetchPypi 
# Deps
, fonttools
#, glyphslib
#, ufo2ft
#, fontMath
#, booleanOperations
#, ufoLib2
, attrs
}:
let 
  defcon = buildPythonPackage rec {
    pname = "defcon";
    version = "0.7.2";
    propagatedBuildInputs = [
      fonttools
    ];
    src = fetchPypi {
      inherit pname version;
      extension = "zip";
      sha256 = "1lfqsvxmq1j0nvp26gidnqkj1dyxv7jalc6i7fz1r3nc7niflrqr";
    };
    doCheck = false;
  };
  cu2qu = buildPythonPackage rec {
    pname = "cu2qu";
    version = "1.6.7";
    propagatedBuildInputs = [
      fonttools
      defcon
    ];
    src = fetchPypi {
      inherit pname version;
      extension = "zip";
      sha256 = "0fc1pmksbpxapa1kw47hf7vspkgaadq3qsd2wxj2jyn274jrd7jm";
    };
    doCheck = false;
  };
  fontmake = buildPythonPackage rec {
    pname = "fontmake";
    version = "2.2.0";
    propagatedBuildInputs = [
      fonttools
      attrs
      cu2qu
    ];
    src = fetchPypi {
      inherit pname version;
      extension = "zip";
      sha256 = "09m66bn8xrrkz6wwi0r5nb68bb4ahizrk44mvyfbvzacxhj9b8z7";
    };
    doCheck = false;
  };
in fontmake
#pkgs.stdenv.mkDerivation {
#    nativeBuildInputs = with pkgs [
#      ttfautohint-nox
#      python38Packages.fonttools
#    ];
#  };
