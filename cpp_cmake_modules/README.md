## Develop Build

```console
$ nix develop
$ cmake -B build -GNinja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
$ cmake --build build
```
