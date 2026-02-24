# omp — Prebuilt LLVM libomp

Prebuilt static + shared libomp binaries from LLVM, for Bazel and general use.

## Platforms

| Platform | Triple | Variants | Format |
|----------|--------|----------|--------|
| Linux x86_64 | x86_64-unknown-linux-gnu | static + shared | tar.gz |
| Linux arm64 | aarch64-unknown-linux-gnu | static + shared | tar.gz |
| macOS x86_64 | x86_64-apple-darwin | static + shared | tar.gz |
| macOS arm64 | arm64-apple-darwin | static + shared | tar.gz |
| Windows x86_64 | x86_64-pc-windows-msvc | shared only | zip |

## Contents

Each release tarball contains:

```
omp-{version}-{triple}/
  lib/
    libomp.a          (static, unix only)
    libomp.so         (shared, linux)
    libomp.dylib      (shared, macos)
    libomp.lib        (import lib, windows)
    libgomp.so        (GCC compat alias, linux)
    libiomp5.so       (Intel compat alias, linux)
    libiomp5md.lib    (Intel compat import lib, windows)
  bin/
    libomp.dll        (shared, windows)
    libiomp5md.dll    (Intel compat, windows)
  include/
    omp.h
    omp-tools.h       (unix only, requires OMPT)
    ompt.h            (unix only)
    ompx.h
  LICENSE.TXT
```

## Bazel usage

```starlark
# MODULE.bazel
bazel_dep(name = "omp", version = "21.1.8")

omp = use_extension("@omp//:extensions.bzl", "omp")
use_repo(omp, "libomp")
```

```starlark
# BUILD.bazel
load("@omp//:defs.bzl", "OMP_COPTS")

cc_binary(
    name = "my_app",
    srcs = ["main.c"],
    copts = OMP_COPTS,
    deps = ["@libomp//:omp"],
)
```

`OMP_COPTS` handles platform differences automatically (Linux: `-fopenmp`,
macOS: `-Xclang -fopenmp` to bypass Apple Clang's driver restriction,
Windows: `/openmp`).

See `examples/` for test targets.

## Build configuration

- `CMAKE_INTERPROCEDURAL_OPTIMIZATION=ON` (LTO, unix only)
- `LIBOMP_OMPT_SUPPORT=ON` (unix), `OFF` (windows — upstream blocks it)
- `LIBOMP_INSTALL_ALIASES=ON` (unix — libgomp/libiomp5 compat)
- `OPENMP_ENABLE_LIBOMPTARGET=OFF` (no GPU offloading)
- Linux builds use Alpine musl for maximum portability
- Windows: shared-only (upstream cmake blocks static on Windows)
