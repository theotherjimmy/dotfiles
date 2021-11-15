{rustPlatform, fetchFromGitHub, scdoc, installShellFiles}:

rustPlatform.buildRustPackage rec {
  pname = "monitor-layout";
  version = "0.3.0";
  src = fetchFromGitHub {
    owner = "theotherjimmy";
    repo = "autorandr-rs";
    rev = "cecda70c66db983c1fc7e4a04d8f2cec91f16f13";
    hash = "sha256-0Quye6D1JjsVStADClR9MXlsH2i6ihBV9iOgQCBx9+E=";
  };
  cargoHash = "sha256-2D2iKgtYdJZ7AypPhJ2n0GCpEfwFKNEPbjRxtcicbmw=";
  nativeBuildInputs = [ scdoc installShellFiles ];
  preFixup = ''
    installManPage $releaseDir/build/${pname}-*/out/monitor-layout.1
    installManPage $releaseDir/build/${pname}-*/out/monitor-layout.5
  '';
}
