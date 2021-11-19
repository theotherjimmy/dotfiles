{rustPlatform, fetchFromGitHub, scdoc, installShellFiles}:

rustPlatform.buildRustPackage rec {
  pname = "fre";
  version = "0.3.0";
  src = fetchFromGitHub {
    owner = "camdencheek";
    repo = pname;
    rev = "ca87cf1e6c34a4d0e4f4943befa5b942b5c18fec";
    hash = "sha256-oct4QZQEmZ5w6157mvMx95cqQv0MmBEFnX795HSL1P0=";
  };
  cargoHash = "sha256-YEi2swsXdFcLB/4Ewux6YMxJNHdU64coATBYLlS9bbU=";
}
