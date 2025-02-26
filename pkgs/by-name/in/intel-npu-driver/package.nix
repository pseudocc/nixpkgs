{
  lib,
  stdenv,
  udev,
  openssl,
  boost,
  cmake,
  git,
  level-zero,
  fetchFromGitHub,
  ...
}:

let
  version = "1.13.0";
  artifacts = stdenv.mkDerivation {
    name = "intel-npu-driver-cmake-build";
    src = fetchFromGitHub {
      owner = "intel";
      repo = "linux-npu-driver";
      rev = "v${version}";
      fetchSubmodules = true;
      hash = "sha256-+WPJrxwUT0UwU8VpJ4Wnmu/hLkdCDwiidGQwjl1Nvxk=";
    };

    buildInputs = [
      udev
      openssl
      boost
      level-zero
    ];

    nativeBuildInputs = [
      cmake
      git
    ];

    installPhase = ''
      cmake --install . --component level-zero-npu
      cmake --install . --component validation-npu
    '';

    meta = {
      homepage = "https://github.com/intel/linux-npu-driver";
      description = "Intel NPU (Neural Processing Unit) Standalone Driver";
      platforms = [ "x86_64-linux" ];
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ pseudocc ];
    };
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = "intel-npu-driver";
  src = artifacts;

  installPhase = ''
    cp -rP ${artifacts}/lib $out
  '';

  passthru.validation = stdenv.mkDerivation {
    inherit version;
    pname = "intel-npu-driver-validation";
    src = artifacts;

    buildInputs = [ artifacts ];
    installPhase = ''
      cp -r ${artifacts}/bin $out
    '';

    meta = artifacts.meta // {
      description = "Intel NPU (Neural Processing Unit) Standalone Driver Validation";
      mainProgram = "npu-umd-test";
    };
  };

  meta = artifacts.meta;
}
