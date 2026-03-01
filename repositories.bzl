"""Repository rules for downloading prebuilt libomp binaries."""

_WASM_TRIPLE = "wasm32-unknown-emscripten"

_BUILD_FILE_CONTENT = '''\
load("@rules_cc//cc:defs.bzl", "cc_import", "cc_library")

cc_import(
    name = "libomp",
    static_library = select({
        "@platforms//os:emscripten": "wasm32/lib/libomp.a",
        "@platforms//os:windows": None,
        "//conditions:default": "lib/libomp.a",
    }),
    shared_library = select({
        "@platforms//os:emscripten": None,
        "@platforms//os:linux": "lib/libomp.so",
        "@platforms//os:macos": "lib/libomp.dylib",
        "@platforms//os:windows": "bin/libomp.dll",
        "//conditions:default": None,
    }),
    interface_library = select({
        "@platforms//os:windows": "lib/libomp.lib",
        "//conditions:default": None,
    }),
    hdrs = glob(["include/*.h", "wasm32/include/*.h"]),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "omp",
    deps = [":libomp"],
    includes = ["include", "wasm32/include"],
    linkopts = select({
        "@platforms//os:linux": ["-lpthread", "-ldl", "-lrt"],
        "//conditions:default": [],
    }),
    visibility = ["//visibility:public"],
)
'''

def _detect_host_triple(repository_ctx):
    """Detect host platform and return target triple."""
    os = repository_ctx.os.name.lower()
    arch = repository_ctx.os.arch.lower()

    if "linux" in os:
        if arch in ("aarch64", "arm64"):
            return "aarch64-unknown-linux-gnu"
        return "x86_64-unknown-linux-gnu"
    elif "mac" in os:
        if arch in ("aarch64", "arm64"):
            return "arm64-apple-darwin"
        return "x86_64-apple-darwin"
    elif "win" in os:
        return "x86_64-pc-windows-msvc"
    else:
        fail("unsupported os: " + os)

def _download(repository_ctx, version, triple, sha256, output = ""):
    """Download and extract a release archive."""
    if not sha256:
        fail("no sha256 for %s @ %s -- add to _CHECKSUMS or provide via tag" % (triple, version))
    ext = "zip" if "windows" in triple else "tar.gz"
    filename = "omp-%s-%s.%s" % (version, triple, ext)
    url = "https://github.com/%s/%s/releases/download/v%s/%s" % (
        repository_ctx.attr.repo_owner,
        repository_ctx.attr.repo_name,
        version,
        filename,
    )
    repository_ctx.download_and_extract(
        url = url,
        sha256 = sha256,
        output = output,
        stripPrefix = "omp-%s" % version,
    )

def _omp_repository_impl(repository_ctx):
    version = repository_ctx.attr.version
    sha256 = repository_ctx.attr.sha256
    triple = repository_ctx.attr.target_triple or _detect_host_triple(repository_ctx)

    # host
    _download(repository_ctx, version, triple, sha256.get(triple, ""))

    # wasm (always, <1MB)
    _download(repository_ctx, version, _WASM_TRIPLE, sha256.get(_WASM_TRIPLE, ""), output = "wasm32")

    repository_ctx.file("BUILD.bazel", _BUILD_FILE_CONTENT)

omp_repository = repository_rule(
    implementation = _omp_repository_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "target_triple": attr.string(default = ""),
        "repo_owner": attr.string(default = "miinso"),
        "repo_name": attr.string(default = "omp"),
        "sha256": attr.string_dict(default = {}),
    },
)
