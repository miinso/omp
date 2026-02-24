"""Public API for omp consumers."""

# OpenMP compiler flags for each platform.
# Apple Clang's driver rejects -fopenmp; -Xclang bypasses to cc1 which
# has the full OpenMP lowering code.
OMP_COPTS = select({
    "@platforms//os:windows": ["/openmp"],
    "@platforms//os:macos": ["-Xclang", "-fopenmp"],
    "//conditions:default": ["-fopenmp"],
})
