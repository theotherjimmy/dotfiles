{rustPlatform, fetchFromGitHub, rust-bin}:

rustPlatform.buildRustPackage rec {
  name = "rcalc";
  src = fetchFromGitHub {
    owner = "theotherjimmy";
    repo = name;
    rev = "b57bbe405afe27995f4bccf8740d32ea2e7670d7";
    hash = "sha256-rFHSk/kM2PIRyaRyx6f7R13FlB5WJHEO3kbb3S1kFxg=";
  };
  cargoHash = "sha256-hYO0zEynBCt5esi824PxguikwU59SeXp9xhk8Iqwmo8=";
  nativeBuildInputs = [
    rust-bin.nightly."2021-03-23".rust
  ];
}
