{ lib, stdenv, cmake, ninja, cpp_cmake_lib_playground }:

stdenv.mkDerivation {
  name = "cpp_cmake_tests";
  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [
    cpp_cmake_lib_playground
  ];
  src = with lib.fileset; toSource {
    root = ./.;
    fileset = fileFilter
      (file: ! (lib.elem file.name [ "default.nix" ]))
      ./.;
  };

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/main | grep 'hello 42'
    runHook postInstallCheck
  '';
}
