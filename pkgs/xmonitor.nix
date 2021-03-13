{ stdenv, fetchFromGitHub, xorg}:

stdenv.mkDerivation rec {
  name = "xmonitor";
  version = "git";
  src = fetchFromGitHub {
    repo = name;
    owner = "Triagle";
    rev = "9df8088c67a4f60894b0ede8f8cb183f1d13322b";
    sha256 = "0jqls2s5f7vrkq610kdkxpsviia9x82blcvlv31svfn3hgqn0fvh";
  };
  buildInputs = with xorg; [
    libX11
    libXrandr
    libXinerama
  ];
  PREFIX = "\${out}";
}
