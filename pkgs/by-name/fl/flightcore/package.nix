{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  cargo-tauri_1,
  nodejs,
  jq,
  moreutils,
  vue-tsc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "FlightCore";
  version = "2.26.2";

  src = fetchFromGitHub {
    owner = "R2NorthstarTools";
    repo = "FlightCore";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MJruUo9Sefps8bCKjdkBvD1kJ8mJhVP7DW+nHYwNfvU=";
  };

  postPatch = ''
    jq '.tauri.bundle.active = false' src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json
    jq '.dependencies += .devDependencies' src-vue/package.json | sponge src-vue/package.json
    jq '.dependencies += .devDependencies' package.json | sponge package.json
    jq -s '.[0] * .[1]' package.json src-vue/package.json | sponge package.json
  '';

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-Z2HR+BQfMwurLLn8YiLufK13rDXIm5rXdStJdDnfICw=";
    forceGitDeps = true;
  };

  npmFlags = [ "--legacy-peer-deps" ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      cargoRoot
      ;
    hash = "sha256-c0CK8EXUaXgli89HKwN/s/Yqnz+QdwE0eoV6Az9OO3o=";
  };

  cargoRoot = "src-tauri";

  buildAndTestSubdir = finalAttrs.cargoRoot;

  nativeBuildInputs = [
    jq
    moreutils
    npmHooks.npmConfigHook
    nodejs
    rustPlatform.cargoSetupHook
    cargo-tauri_1.hook
    rustPlatform.cargoCheckHook
    vue-tsc
  ];
  buildInputs = [

  ];

  meta = {
    description = "An installer, updater, and mod-manager for Titanfall 2's Northstar Mod.";
    homepage = "https://github.com/R2NorthstarTools/FlightCore";
    mainProgram = "flightcore";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ teknolog1k ];
  };
})
