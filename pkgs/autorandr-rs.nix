{rustPlatform, fetchFromGitHub, scdoc, installShellFiles}:

rustPlatform.buildRustPackage rec {
  pname = "autorandr-rs";
  version = "0.3.0";
  src = fetchFromGitHub {
    owner = "theotherjimmy";
    repo = pname;
    rev = "564930af02c556f5615f446dcf33dea1d39fa347";
    hash = "sha256-xPjQ97xUGFx874ojwBB6jiH9Rn0y/aVUTKTdh13PMIY=";
  };
  cargoHash = "sha256-aEzw02J6Tw0K5kE5Cny/ktADzbJXbE2QEz7dP+7mrNE=";
  nativeBuildInputs = [ scdoc installShellFiles ];
  preFixup = ''
    installManPage $releaseDir/build/${pname}-*/out/autorandrd.1
    installManPage $releaseDir/build/${pname}-*/out/randr-edid.1
    installManPage $releaseDir/build/${pname}-*/out/autorandrd.5
  '';
}
