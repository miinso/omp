"""Repository rules for downloading prebuilt libomp binaries."""

# platform detection → target triple mapping
_PLATFORM_MAP = {
    ("linux", "amd64"): ("x86_64-unknown-linux-gnu", "tar.gz"),
    ("linux", "x86_64"): ("x86_64-unknown-linux-gnu", "tar.gz"),
    ("linux", "aarch64"): ("aarch64-unknown-linux-gnu", "tar.gz"),
    ("mac os x", "x86_64"): ("x86_64-apple-darwin", "tar.gz"),
    ("mac os x", "aarch64"): ("arm64-apple-darwin", "tar.gz"),
    ("mac os", "x86_64"): ("x86_64-apple-darwin", "tar.gz"),
    ("mac os", "aarch64"): ("arm64-apple-darwin", "tar.gz"),
    ("windows", "amd64"): ("x86_64-pc-windows-msvc", "zip"),
    ("windows", "x86_64"): ("x86_64-pc-windows-msvc", "zip"),
}

_BUILD_FILE_CONTENT = """\
load("@rules_cc//cc:defs.bzl", "cc_import", "cc_library")

cc_import(
    name = "omp_import",
    static_library = select({{
        "@platforms//os:windows": None,
        "//conditions:default": "lib/libomp.a",
    }}),
    shared_library = select({{
        "@platforms//os:linux": "lib/libomp.so",
        "@platforms//os:macos": "lib/libomp.dylib",
        "@platforms//os:windows": "bin/libomp.dll",
        "//conditions:default": None,
    }}),
    interface_library = select({{
        "@platforms//os:windows": "lib/libomp.lib",
        "//conditions:default": None,
    }}),
    hdrs = glob(["include/*.h"]),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "omp",
    deps = [":omp_import"],
    includes = ["include"],
    visibility = ["//visibility:public"],
)
"""

def _get_platform_info(repository_ctx):
    """Detect host platform and return (target_triple, file_ext)."""
    os_name = repository_ctx.os.name.lower()
    arch = repository_ctx.os.arch.lower()

    # normalize os name
    if "linux" in os_name:
        os_key = "linux"
    elif "mac" in os_name:
        os_key = "mac os x"
    elif "windows" in os_name or "win" in os_name:
        os_key = "windows"
    else:
        fail("unsupported os: " + os_name)

    key = (os_key, arch)
    if key not in _PLATFORM_MAP:
        fail("unsupported platform: os=%s arch=%s" % (os_name, arch))

    return _PLATFORM_MAP[key]

def _omp_repository_impl(repository_ctx):
    version = repository_ctx.attr.version
    repo_owner = repository_ctx.attr.repo_owner
    repo_name = repository_ctx.attr.repo_name

    triple, ext = _get_platform_info(repository_ctx)

    filename = "omp-%s-%s.%s" % (version, triple, ext)
    url = "https://github.com/%s/%s/releases/download/v%s/%s" % (
        repo_owner,
        repo_name,
        version,
        filename,
    )

    sha256 = repository_ctx.attr.sha256.get(triple, "")

    repository_ctx.download_and_extract(
        url = url,
        sha256 = sha256,
        stripPrefix = "omp-%s" % version,
    )

    repository_ctx.file("BUILD.bazel", _BUILD_FILE_CONTENT)

omp_repository = repository_rule(
    implementation = _omp_repository_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "repo_owner": attr.string(default = "miinso"),
        "repo_name": attr.string(default = "omp"),
        "sha256": attr.string_dict(default = {}),
    },
)
