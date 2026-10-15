{ lib, rustPlatform, fetchFromGitHub, git }:

rustPlatform.buildRustPackage {
  pname = "pushtrack";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "TemelGunaydin";
    repo = "PushTrack";
    rev = "f873121590081f0f054c880ad30c9a6085cafa35";
    hash = "sha256-ZySjSGW5gTv5Ds3acbvEQEkasitVV94FU28oZ+KX8Jo=";
  };

  cargoHash = "sha256-0kjsuLrNBV/WSw7ux+bX5YB2gPq9tdzGfg35Gik3jGk=";
  nativeCheckInputs = [ git ];

  meta = {
    description = "Terminal dashboard for unpushed commits and uncommitted work";
    homepage = "https://github.com/TemelGunaydin/PushTrack";
    mainProgram = "pushtrack";
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
  };
}
