{rustPlatform, fetchFromGitHub, scdoc, installShellFiles}:

rustPlatform.buildRustPackage rec {
  name = "autorandr-rs";
  src = fetchFromGitHub {
    owner = "theotherjimmy";
    repo = name;
    rev = "d9698f00839c84620c5d93d51807d0d0e5ca633d";
    hash = "sha256-pUbaUoMu7NZQ7Wy7/TGEcqqMCweUFVcJEEk6zxIaMfk=";
  };
  cargoHash = "sha256-esTVrs2+vd6bcKqjBMEPJLy+QXlv5XWNuy4amo9epbs=";
  nativeBuildInputs = [ scdoc installShellFiles ];
  preFixup = ''
    installManPage $releaseDir/build/${name}-*/out/autorandrd.1
    installManPage $releaseDir/build/${name}-*/out/randr-edid.1
    installManPage $releaseDir/build/${name}-*/out/autorandrd.5
  '';
}
