{rustPlatform, fetchFromGitHub, lib}:

rustPlatform.buildRustPackage rec {
  name = "rpn-c";
  src = fetchFromGitHub {
    owner = "KayJay7";
    repo = name;
    rev = "54bb4f6e3acf9b0e261a401750b7d8c1ddc6fc8d";
  };
  cargoHash = lib.fakehash;
}
