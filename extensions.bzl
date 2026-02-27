"""Module extension for downloading prebuilt libomp."""

load(":repositories.bzl", "omp_repository")

_DEFAULT_VERSION = "21.1.8"

# sha256 checksums keyed by llvm version → target triple
# append new versions here as artifacts are built
_CHECKSUMS = {
    "21.1.8": {
        "aarch64-unknown-linux-gnu": "9e62d9f0069a8743486f68a6988f6efebca9d5ec9953ed44acef7fb92488ddad",
        "arm64-apple-darwin": "817ec3871f09bfe427305fce083c11d762541268fdb1a69169f0db2a28e45237",
        "wasm32-unknown-emscripten": "0cc76f8652ddc89530e4900bcb9eb94930835487ce1a1b4a13d44b4952873d44",
        "x86_64-apple-darwin": "ff8730e59a9c851583767ab73cc6dd3b7df25659391035b8339bbaae1e4e2ce4",
        "x86_64-pc-windows-msvc": "d5de8a0efbce210a1500691be143a7a9edfb4377642cbc9e20018add2a4fdc95",
        "x86_64-unknown-linux-gnu": "9cc52f0c7598a3846f95770c7c3d425c67e9ad6e454849eda890db5318021f48",
    },
}

_version_tag = tag_class(attrs = {
    "version": attr.string(default = _DEFAULT_VERSION),
    "target_triple": attr.string(default = ""),
    "sha256": attr.string_dict(default = {}),
})

def _omp_impl(module_ctx):
    version = _DEFAULT_VERSION
    sha256 = {}
    target_triple = ""

    # root module tags take priority over transitive deps
    for mod in module_ctx.modules:
        if not mod.is_root:
            continue
        for tag in mod.tags.version:
            if tag.version:
                version = tag.version
            if tag.target_triple:
                target_triple = tag.target_triple
            if tag.sha256:
                sha256 = dict(tag.sha256)

    # fall back to built-in checksums if no explicit sha256 provided
    if not sha256 and version in _CHECKSUMS:
        sha256 = dict(_CHECKSUMS[version])

    omp_repository(
        name = "omp",
        version = version,
        target_triple = target_triple,
        sha256 = sha256,
    )

libomp = module_extension(
    implementation = _omp_impl,
    tag_classes = {"version": _version_tag},
)
