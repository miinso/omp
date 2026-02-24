"""Module extension for downloading prebuilt libomp."""

load(":repositories.bzl", "omp_repository")

_DEFAULT_VERSION = "21.1.8"

# sha256 checksums for the default version
_DEFAULT_SHA256 = {
    "aarch64-unknown-linux-gnu": "3cd762ec9a5420203423db158eb6d5dca873a694b659ba735f714e4f6b4d7d5e",
    "arm64-apple-darwin": "b41bebb1669d8871140d4b7bebe9075e244d9200b21ffbdd65ae69fc218abcb6",
    "x86_64-apple-darwin": "69ef1633dbbaf01cf73ce306ebaf8e49cc840fa0ed7f3383df0d761a294ecbf2",
    "x86_64-pc-windows-msvc": "b75913ad8673382cc4c9dffa54b96e566278ea5ed2961dac8c0821188d2967f2",
    "x86_64-unknown-linux-gnu": "9390a51b66a4511020a5c11b5e48c617dc50754527bfd7dfb5cffd8cfabd6dd8",
}

_version_tag = tag_class(attrs = {
    "version": attr.string(default = _DEFAULT_VERSION),
    "sha256": attr.string_dict(default = {}),
})

def _omp_impl(module_ctx):
    version = _DEFAULT_VERSION
    sha256 = dict(_DEFAULT_SHA256)

    for mod in module_ctx.modules:
        for tag in mod.tags.version:
            if tag.version:
                version = tag.version
            if tag.sha256:
                sha256 = dict(tag.sha256)

    omp_repository(
        name = "omp_prebuilt",
        version = version,
        sha256 = sha256,
    )

omp = module_extension(
    implementation = _omp_impl,
    tag_classes = {"version": _version_tag},
)
