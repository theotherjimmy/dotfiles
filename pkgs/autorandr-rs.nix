{rustPlatform, fetchFromGitHub, scdoc, installShellFiles}:

rustPlatform.buildRustPackage rec {
  name = "autorandr-rs";
  src = fetchFromGitHub {
    owner = "theotherjimmy";
    repo = name;
    rev = "51a705e3a3761d32b9e068f48fc34722ca3d2ab7";
    hash = "sha256-ryK7/VYxo/ssMBYmGCJBk7sz+pp2MNPhHJx9LNcm6Lc=";
  };
  cargoHash = "sha256-Rb81EXPqb7ydz5FA8AHwjnNIxp0Mr8vVRPx0sGIXqyY=";
  nativeBuildInputs = [ scdoc installShellFiles ];
  preFixup = ''
    installManPage $releaseDir/build/${name}-*/out/${name}.1
    installManPage $releaseDir/build/${name}-*/out/${name}.5
  '';
}
