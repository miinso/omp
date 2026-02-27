"""Module extension for downloading prebuilt libomp."""

load(":repositories.bzl", "omp_repository")

_DEFAULT_VERSION = "21.1.8"

# sha256 checksums keyed by llvm version → target triple
# append new versions here as artifacts are built
_CHECKSUMS = {
    "21.1.8": {
        "aarch64-unknown-linux-gnu": "d64c6fd4d4f15906bfd2b38960e33f7d8dfd0428c93125d6826e9398111e2f01",
        "arm64-apple-darwin": "20bf7964a290b3a9cac48f3f940c64176e40ab14a41c83adfade159a9132eb9a",
        "x86_64-apple-darwin": "e71c4aa6d5c24488a4177a51f1e5e2bb936d6f105db9eb36473991237df3b6d9",
        "x86_64-pc-windows-msvc": "48b191b99e91445afe052822ad9cce968e5f6ce6949406092fb4886367a1161b",
        "x86_64-unknown-linux-gnu": "0928dfef5d30ea77e37bca80b9b1c01ffb08dde1450f675170bebce853f7691f",
    },
}

_version_tag = tag_class(attrs = {
    "version": attr.string(default = _DEFAULT_VERSION),
    "sha256": attr.string_dict(default = {}),
})

def _omp_impl(module_ctx):
    version = _DEFAULT_VERSION
    sha256 = {}

    # root module tags take priority over transitive deps
    for mod in module_ctx.modules:
        if not mod.is_root:
            continue
        for tag in mod.tags.version:
            if tag.version:
                version = tag.version
            if tag.sha256:
                sha256 = dict(tag.sha256)

    # fall back to built-in checksums if no explicit sha256 provided
    if not sha256 and version in _CHECKSUMS:
        sha256 = dict(_CHECKSUMS[version])

    omp_repository(
        name = "omp",
        version = version,
        sha256 = sha256,
    )

libomp = module_extension(
    implementation = _omp_impl,
    tag_classes = {"version": _version_tag},
)
