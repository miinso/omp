#!/usr/bin/env python3
"""validate libomp install: headers, libs, compile+link+run test."""

from __future__ import annotations

import argparse
import os
import platform
import subprocess
import sys
import tempfile
from pathlib import Path

# minimal omp C test
OMP_TEST_C = r"""
#include <omp.h>
#include <stdio.h>

int main(void) {
    int nthreads = 0;
    #pragma omp parallel
    {
        #pragma omp atomic
        nthreads++;
    }
    printf("threads=%d\n", nthreads);
    if (nthreads < 1) return 1;
    printf("omp_get_max_threads=%d\n", omp_get_max_threads());
    return 0;
}
"""

REQUIRED_HEADERS = ["omp.h"]
# omp-tools.h requires OMPT which is not available on Windows
OPTIONAL_HEADERS = ["omp-tools.h", "ompt.h", "ompx.h", "omp_lib.h"]


def check_headers(include_dir: Path) -> bool:
    ok = True
    for h in REQUIRED_HEADERS:
        p = include_dir / h
        if not p.exists():
            print(f"FAIL: missing required header {p}")
            ok = False
        else:
            print(f"  ok: {p}")
    for h in OPTIONAL_HEADERS:
        p = include_dir / h
        if p.exists():
            print(f"  ok: {p} (optional)")
        else:
            print(f"  skip: {p} (optional, not present)")
    return ok


def check_libs(lib_dir: Path, is_windows: bool) -> bool:
    ok = True
    if is_windows:
        # windows: expect import lib + dll
        candidates = ["omp.lib", "libomp.lib", "libomp.dll.lib"]
        found = any((lib_dir / c).exists() for c in candidates)
        if not found:
            print(f"FAIL: no import lib found in {lib_dir} (checked {candidates})")
            ok = False
        else:
            print(f"  ok: import lib found in {lib_dir}")
    else:
        static = lib_dir / "libomp.a"
        if not static.exists():
            print(f"FAIL: missing static lib {static}")
            ok = False
        else:
            size_mb = static.stat().st_size / (1024 * 1024)
            print(f"  ok: {static} ({size_mb:.1f} MB)")

        # shared lib is optional (may not be built)
        if sys.platform == "darwin":
            shared = lib_dir / "libomp.dylib"
        else:
            shared = lib_dir / "libomp.so"
        if shared.exists():
            print(f"  ok: {shared}")
        else:
            print(f"  skip: {shared} (not present)")
    return ok


def compile_and_run(
    install_dir: Path, is_windows: bool, compiler: str | None
) -> bool:
    include_dir = install_dir / "include"
    lib_dir = install_dir / "lib"

    if compiler is None:
        compiler = "cl" if is_windows else "cc"

    with tempfile.TemporaryDirectory() as tmpdir:
        src = Path(tmpdir) / "test_omp.c"
        src.write_text(OMP_TEST_C)

        if is_windows:
            exe = Path(tmpdir) / "test_omp.exe"
            cmd = [
                compiler,
                "/nologo",
                f"/I{include_dir}",
                "/openmp",
                str(src),
                f"/Fe{exe}",
                f"/link",
                f"/LIBPATH:{lib_dir}",
            ]
        else:
            exe = Path(tmpdir) / "test_omp"
            cmd = [
                compiler,
                "-fopenmp",
                f"-I{include_dir}",
                str(src),
                "-o",
                str(exe),
                f"-L{lib_dir}",
                "-lomp",
                "-lpthread",
            ]

        print(f"  compile: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"FAIL: compilation failed\n{result.stderr}")
            return False
        print("  ok: compiled")

        if not exe.exists():
            print(f"FAIL: exe not found at {exe}")
            return False

        env = os.environ.copy()
        env["OMP_NUM_THREADS"] = "2"
        if is_windows:
            bin_dir = install_dir / "bin"
            env["PATH"] = str(bin_dir) + ";" + str(lib_dir) + ";" + env.get("PATH", "")
        else:
            env["LD_LIBRARY_PATH"] = str(lib_dir)

        print(f"  run: {exe}")
        result = subprocess.run(
            [str(exe)], capture_output=True, text=True, env=env, timeout=30
        )
        if result.returncode != 0:
            print(f"FAIL: execution failed (rc={result.returncode})\n{result.stderr}")
            return False

        output = result.stdout.strip()
        print(f"  output: {output}")

        if "threads=" not in output:
            print("FAIL: unexpected output format")
            return False

        print("  ok: run succeeded")
        return True


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--install-dir", required=True, help="libomp install prefix")
    parser.add_argument("--compiler", default=None, help="C compiler to use")
    parser.add_argument(
        "--skip-run", action="store_true", help="skip compile+run test"
    )
    args = parser.parse_args()

    install_dir = Path(args.install_dir).resolve()
    is_windows = platform.system() == "Windows"

    include_dir = install_dir / "include"
    lib_dir = install_dir / "lib"

    print(f"=== libomp validation: {install_dir} ===")
    print(f"platform: {platform.system()} {platform.machine()}")

    all_ok = True

    print("\n--- headers ---")
    if not check_headers(include_dir):
        all_ok = False

    print("\n--- libraries ---")
    if not check_libs(lib_dir, is_windows):
        all_ok = False

    if not args.skip_run:
        print("\n--- compile+link+run ---")
        if not compile_and_run(install_dir, is_windows, args.compiler):
            all_ok = False

    print()
    if all_ok:
        print("ALL CHECKS PASSED")
    else:
        print("SOME CHECKS FAILED")
        sys.exit(1)


if __name__ == "__main__":
    main()
