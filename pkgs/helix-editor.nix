{ fetchFromGitHub, lib, makeRustPlatform, makeWrapper, rust-bin }:
let 
  rustPlatform = makeRustPlatform {
    cargo = rust-bin.nightly.latest.default;
    rustc = rust-bin.nightly.latest.default;
  };
in rustPlatform.buildRustPackage rec {
  pname = "helix";
  version = "git";

  src = fetchFromGitHub {
    owner = "helix-editor";
    repo = pname;
    rev = "cfc82858679d264d178a0b072da26828e685de12";
    fetchSubmodules = true;
    sha256 = "sha256-U89DTJ+YsaYV1GWr09nM6IsR7Icn1mBzwDGkLXNsi/M=";
  };

  cargoSha256 = "sha256-dghI8nd1srronzBRJFYGxmaA4X7y7xJao5+ylbFyY84=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    mkdir -p $out/lib
    cp -r runtime $out/lib
  '';
  postFixup = ''
    wrapProgram $out/bin/hx --set HELIX_RUNTIME $out/lib/runtime
  '';

  meta = with lib; {
    description = "A post-modern modal text editor";
    homepage = "https://helix-editor.com";
    license = licenses.mpl20;
    mainProgram = "hx";
    maintainers = with maintainers; [ yusdacra ];
  };
}
