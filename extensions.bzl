"""Module extension for downloading prebuilt libomp."""

load(":repositories.bzl", "omp_repository")

_DEFAULT_VERSION = "21.1.8"

# sha256 checksums keyed by llvm version → target triple
# append new versions here as artifacts are built
_CHECKSUMS = {
    "21.1.8": {
        "aarch64-unknown-linux-gnu": "953820d374061eeb99e12178ca637b7960542dc3550af43f6730bc0088166e73",
        "arm64-apple-darwin": "66fa76a64abe99c147a99ec5d9dac376c3eba7cedda2b50baa329d4e523f3b4f",
        "wasm32-unknown-emscripten": "b5953c93108f26c4018dc028ca261108fd97729a9e3366a4871fb4ee03661641",
        "x86_64-apple-darwin": "275e9e25e09362d70f7c8fed44cbfeb7d49844e0b24365e7c8836f8e4bbc726c",
        "x86_64-pc-windows-msvc": "6f841594f7956f4b8345cdb5e9685f756f1bb89ff8280b39defc6ee8ac63bf00",
        "x86_64-unknown-linux-gnu": "f7c78d5cff144858bfd2cdb184a96916eb2feee6d0c28843e2d3aadce03c1232",
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
