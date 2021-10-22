{rustPlatform, fetchFromGitHub, scdoc, installShellFiles}:

rustPlatform.buildRustPackage rec {
  pname = "monitor-layout";
  version = "0.3.0";
  src = fetchFromGitHub {
    owner = "theotherjimmy";
    repo = "autorandr-rs";
    rev = "633c9c0809f1389bed5c8b1654b8ce837dbe9b67";
    hash = "sha256-NphhIjmWN2JpC+qRTMNXgznLoZ4SXMDvqR4tDwCnhU4=";
  };
  cargoHash = "sha256-+nHhZeZMftfFleqMd3OsqDka6T34JUDImQ2/GryiROA=";
  nativeBuildInputs = [ scdoc installShellFiles ];
  preFixup = ''
    installManPage $releaseDir/build/${pname}-*/out/monitor-layout.1
    installManPage $releaseDir/build/${pname}-*/out/monitor-layout.5
  '';
}
