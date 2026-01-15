{ stdenv
, lib
, runCommand
, subflake_pkgs
, callPackage
}:

let
  mkCheck = name: cmd:
    runCommand name { } ''
      ${cmd}
      mkdir -p $out
    '';

  skippedCheck = name: mkCheck name ''
    echo "skipped check '${name}'"
  '';

  enableIf = cond: check:
    if cond
    then check
    else skippedCheck check.name;

  mkOutputCheck = name: pkg: output: mkCheck name ''
    ${pkg}/bin/${pkg.meta.mainProgram} | tee /dev/stderr | grep -q --fixed-strings '${output}'
  '';

  mkExistenceCheck = name: pkg: path: mkCheck name ''
    echo "Checking existence of '${pkg}/${path}"
    test -f '${pkg}/${path}'
  '';

  checks = [
    (mkOutputCheck "cpp_cmake_check" subflake_pkgs.cpp_cmake "gcd(114, 514) = 2")
    (mkOutputCheck "cpp_cmake_modules_check" subflake_pkgs.cpp_cmake_modules "gcd(114, 514) = 2")
    (mkOutputCheck "cpp_meson_check" subflake_pkgs.cpp_meson "welcome: 4")
    (mkOutputCheck "python_uv_check" subflake_pkgs.python_uv "hello world from numpy")
    (mkOutputCheck "rust_check" subflake_pkgs.rust "hello, world!")
    (mkOutputCheck "ts_yarn_check" subflake_pkgs.ts_yarn "Hello: 5 + 10 = 15")

    (skippedCheck "lean")  # nothing can be checked

    # because we cannt run cuda in sandbox
    (enableIf stdenv.targetPlatform.isLinux
      (mkExistenceCheck "cuda_cmake_check" subflake_pkgs.cuda_cmake "bin/cuda_cmake_playground")
    )

    (callPackage ./tests/cpp_cmake_lib_import { })
  ];
in
lib.genAttrs' checks (check: { name = check.name; value = check; })
