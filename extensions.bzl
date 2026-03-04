"""Module extension for downloading prebuilt libomp."""

load(":repositories.bzl", "omp_repository")

_DEFAULT_VERSION = "21.1.8"

# sha256 checksums keyed by llvm version -> target triple
# append new versions here as artifacts are built
_CHECKSUMS = {
    "20.1.0": {
        "aarch64-unknown-linux-gnu": "9198ea56cc547a69a9b0a87fabde15f4282043a405d646b668fcde4d4122bfe0",
        "arm64-apple-darwin": "a381a4509da7b1ac494e51675bc06867c620aa40c6b8db961934ce70169288ed",
        "wasm32-unknown-emscripten": "3317b1bb7722ec4431f66dddf1bbd9b94dfbd692e2ddd5c1d25e8f47f4d1c72c",
        "x86_64-apple-darwin": "e5da610ed094d11468e078992bc66ed1db7aee1ad17f0f873dd293b4f640cdaa",
        "x86_64-pc-windows-msvc": "0416c673fad86f19357cb2044f673a7425e16015f7787a9d5fb0768c485d333a",
        "x86_64-unknown-linux-gnu": "759fd6a5244045cef4462710bcdf0f7ed494a560733ce1e2c1f100fad5f35fbb",
    },
    "20.1.1": {
        "aarch64-unknown-linux-gnu": "f30468a2bb44c47675b62e3ff398be0f629e52ebcc00e91708278256de1942d6",
        "arm64-apple-darwin": "2b32f8c03590eb5403c635b51d3dc26bee2a46eaa3f723fb3a92b45ccf3589e1",
        "wasm32-unknown-emscripten": "e50179b3840e339e112c1da8cc43d08b2c15b30cdcd9d8e37bd34c963c6d5d0d",
        "x86_64-apple-darwin": "1d7a867e983e532200a43192922164f82b43df3f44d235c17b7199f985ee4cee",
        "x86_64-pc-windows-msvc": "be16620da6f74f499f0996283ae43c5f2cfeeedc23223f0b4782e70be22490f6",
        "x86_64-unknown-linux-gnu": "1cc1c386bc009371c2ede8cbbcd6f4730fe73bd536a9b4dfdcbd987147cfa6f3",
    },
    "20.1.2": {
        "aarch64-unknown-linux-gnu": "959350071bfb9e81a616509437f6dae954917d01f5327606d9d30965b3b1b4ff",
        "arm64-apple-darwin": "6c959082bd67abb7cc4d40b90fcff9dd38d919fc6c4c8bcd0b1ac4dec2311921",
        "wasm32-unknown-emscripten": "d470d687c9014ab2e4d87834a23ca8df1249ca42057e7d99539c8a3c1c525304",
        "x86_64-apple-darwin": "2c254ca75513a8ba95a94175b947b976ade7b3a55a591a5d31d76821e62d6774",
        "x86_64-pc-windows-msvc": "25dbf0bd58af37be20cfbb545e722f7580f082adac15376790b42f96411c461a",
        "x86_64-unknown-linux-gnu": "1a20c6efc987e8532938314afd468329c15b6e194be4bdf8e1da236fd5389365",
    },
    "20.1.3": {
        "aarch64-unknown-linux-gnu": "8cb8388e3f91e5d6e33a63aca0f14d91c44c0b2602e115cf2a2eca6bbbe3f1d8",
        "arm64-apple-darwin": "14073daae345f82467f7835988445c5468e93c2b7cb40dd9d8002f82d3950ac9",
        "wasm32-unknown-emscripten": "afbc873cb07b266204255e38abb37daf296a3a612200d081d2f65d20c8005669",
        "x86_64-apple-darwin": "6dc846553ae93a717f6e162b492390b34ec40489f490eee7e278693f7bc5b567",
        "x86_64-pc-windows-msvc": "8fea1e54c0c16e60e7744854b1a76848dedb6a564cdec7218c7b95e527f1e0f7",
        "x86_64-unknown-linux-gnu": "d2b44f70368b75dc746c6f813677c11841d0fd5c6d7a806bd4b52ea76a1384da",
    },
    "20.1.4": {
        "aarch64-unknown-linux-gnu": "07ee4548537ff7cf8bc1fa04151dec287abdc810d729134a6d1b83db4cb3c17e",
        "arm64-apple-darwin": "6eb39cd7e4ff7d5ba1be00f756653bac458bf1c1544721977a3ddc960867e702",
        "wasm32-unknown-emscripten": "ef9bd41948a872c5f1f08fd59e7ad92d87c94dcad411ecc967a23f68da49873f",
        "x86_64-apple-darwin": "d01d9d7b40d54914533aa938d2a2f72eea0fe0a748c50055f8effc9e6e065d47",
        "x86_64-pc-windows-msvc": "bf42a73f815459ad4e8fdd0670fbaa7486892f8d398aa2e63ae4d602626a3e82",
        "x86_64-unknown-linux-gnu": "a36d5e9f5111e4e536af51c0b82b9adaeedc61dfab01b7f3d44e1eb2d79a3c32",
    },
    "20.1.5": {
        "aarch64-unknown-linux-gnu": "7e1c27269ee168f45c0e4decdf393523c91149229c785382f02bfc4ad0629974",
        "arm64-apple-darwin": "59527086c2ecef1c236e6defb596606e14a794100c9de52c85e0fb5c529af41c",
        "wasm32-unknown-emscripten": "7276e75a2c4bd26ed4c9e98bf8a7405584cdf6b6969498580f85e2e0a328bfae",
        "x86_64-apple-darwin": "ff88a32749cd1de2549184387b2aeb86911f77a01592feefef0c10e44c390bc7",
        "x86_64-pc-windows-msvc": "1be4bf3864e9e8e1a6af479ad8e2c92f40c9cbb5288a9e272c191094ee89e263",
        "x86_64-unknown-linux-gnu": "4f801b322ffd4d0ad6786a3b07039b10e506b9b4c5628465230a4425271708f5",
    },
    "20.1.6": {
        "aarch64-unknown-linux-gnu": "b05aa95fc5880491ce66c5a31e34a19d6db07d298d8da39a2e814adf05dc89bb",
        "arm64-apple-darwin": "cac153315fd4198b10c40837009fd3ca4c08252bda4e0699c08f8cfa884b12fc",
        "wasm32-unknown-emscripten": "c62cff35f68a8b4944c61c54923bd7d8675c76331760fe0228f0115f61b3a219",
        "x86_64-apple-darwin": "2501ca1b9e58631bfca2491c898bf1a5ac7ea80b887ef02c27cb6099be788a1b",
        "x86_64-pc-windows-msvc": "81002737ff902e952bbba0ca24b3872e5f44d7931ab013bdf139f5cc1ec6a930",
        "x86_64-unknown-linux-gnu": "2886b040f79fc7dfc21a512e903f5cd3fc8f36d90171b6ac8406f0345f98b3a2",
    },
    "20.1.7": {
        "aarch64-unknown-linux-gnu": "2697835fdeeb515470e446f9c42440a055556bc06808ed2b8b1444e1ef503c73",
        "arm64-apple-darwin": "a433476b5ef3fa60e73acc8547d3f8b5330e61721d3c226ae6356808ef65c8bd",
        "wasm32-unknown-emscripten": "1f2970bc7047af61379a0aa4d31b37a416f672037abd0c084349bf8bae1cc678",
        "x86_64-apple-darwin": "9a371e7f76ffd6fb247e2d231a914606e6ffcaf8fb8772c304722cd984535245",
        "x86_64-pc-windows-msvc": "d2890e02729e88c5743b1e972763c6cb5d633b114c28142945610c7d15743139",
        "x86_64-unknown-linux-gnu": "aad07a2027c4cbfc10836be3b7b8c0e6009e4c14599b6cbee65ead7d18133b67",
    },
    "20.1.8": {
        "aarch64-unknown-linux-gnu": "2020c5a806d1ead99053ce99ce89f011ab35d6a1d48c4ea2368824fac5673cd0",
        "arm64-apple-darwin": "e26426c2078495e2d0b7c1ca96b8b3b657f4ac9bce89e89491726db0c999f07d",
        "wasm32-unknown-emscripten": "87edea2c6e849b208eafc1fa04c015e959da17996a993bc5508b24bdc12f5591",
        "x86_64-apple-darwin": "e7f64921d5b4552bc665c2b4c174eabc4682e3b096e69826b7b0ac6d04d85389",
        "x86_64-pc-windows-msvc": "21a7b6e6b587fc531313f0d0a0b373fe721bd329450fd8332c23416fb42b5792",
        "x86_64-unknown-linux-gnu": "2ba0580cb31df9866b6669675dc05dec4a2a38494c19b8ff3d19ba7c4c9c64b5",
    },
    "21.1.0": {
        "aarch64-unknown-linux-gnu": "a3986d1a76ef150dc8af1473e4dff3ef1d62bd2bc15f7de6c47c80196296be69",
        "arm64-apple-darwin": "6156c30054864748a8f5f75f6e33ea1ea4307484dd29a79161b69e5a84ebac44",
        "wasm32-unknown-emscripten": "f7b7f3e26cdd740f346685156a681472804d8741834d53b96229ed802de9e79e",
        "x86_64-apple-darwin": "7d9309748438089b18ce38096b79f0f902d327dc0ff5da48676b5cff7b5a9623",
        "x86_64-pc-windows-msvc": "3eca974e8945b0550058fcfccf64c43e1172d1210dfa594cf46640df346d9bef",
        "x86_64-unknown-linux-gnu": "685aefc5fe77d6fb612df0f4886e37f8961478fe845c44eba345360ef088f223",
    },
    "21.1.1": {
        "aarch64-unknown-linux-gnu": "a9d0f4c6ff6cea6de5586a9900a0f322d23c1c395be9d7e0b0fdc0af6f511e8f",
        "arm64-apple-darwin": "358f11108f69a30d42b3a8966f5f91dce542cb6552287eae222cf4905662b609",
        "wasm32-unknown-emscripten": "7bcd321ef2e5724655d6ee2db26fe18f0055d94f20a33d5f3d1a71e306a1a042",
        "x86_64-apple-darwin": "18adf402205ef1d9e1b6841f8150927c8ca1f4adc419ed48513e06020523d441",
        "x86_64-pc-windows-msvc": "2e43fe7a79ce69fc4cb86787024d5d1505142bc1d328c4f8e7f42223208b22cc",
        "x86_64-unknown-linux-gnu": "f4c60023955327806d507649bffdb12c3a764157c0c7058ea1a9ae8bf8b6277e",
    },
    "21.1.2": {
        "aarch64-unknown-linux-gnu": "95d8fe1cbce560606b7225fae0ae9803e076b650b7cec62a09ae55bb1f971d82",
        "arm64-apple-darwin": "d8dadd3cf80fdda42267321983f674481d93817d74de3d67f4abb6878a6ac418",
        "wasm32-unknown-emscripten": "53a0c448bec039be38144fd701540a7a84810b2d57197ce26be4fd50dcfce68d",
        "x86_64-apple-darwin": "a2a6301e3731d8ce0c4f07f38a2ee56c479115d1c1c4f0b52305cb9595874788",
        "x86_64-pc-windows-msvc": "a115d88ba5f1a6962f211cb34cdc2bb6a055abc4b2a1beb2fc97a4be60b6f4ba",
        "x86_64-unknown-linux-gnu": "6d181824ccd79c234478629b241d48478eaecd5197d35ea0d41ac099d13d00b8",
    },
    "21.1.3": {
        "aarch64-unknown-linux-gnu": "447e44e7725ca286c2f93683fb556c54901d353bf8c94cf1fd5f9012bd54512a",
        "arm64-apple-darwin": "96cfac90b294343a557adf3d7f3b5d2970cefdda7d445ac400c54620b8e4bc9c",
        "wasm32-unknown-emscripten": "40e40c2c6b1dcb5658fb79decca140a2e2685ea81a79c7f8360c86f9ccea359a",
        "x86_64-apple-darwin": "f75fe658e70893375b2ec5a18bb6db68b5c75fe0ac36d4e5f3a0eeb4350c1622",
        "x86_64-pc-windows-msvc": "264651a308338bc3943445d7dbed8031f5dec97035b864cf16ea7489325dca3d",
        "x86_64-unknown-linux-gnu": "530be11ce65c9ec441a4fd13b4c03eb1848d607658dd1a44a71541561c24958c",
    },
    "21.1.4": {
        "aarch64-unknown-linux-gnu": "8b430b85b15c0549f86f8b15f4b13c3dbbb7443db90140cfc311a6d3811fb7b5",
        "arm64-apple-darwin": "30bf9dc28262febb4ff0e9b882ec3a5b2e6411827b70203c7dc3c9b3406b5876",
        "wasm32-unknown-emscripten": "117ec860da793ca431543b748eb5dc20ecb46ae6daf2001c538ae6c6864adf4f",
        "x86_64-apple-darwin": "37d06e9398ce0f2a92bbad3d8a205393a8676374b7f5ff84e688da218a5210bf",
        "x86_64-pc-windows-msvc": "a6e863e7696525ff381a77cc601cef24c07f02b8dd777594f8da0b8f389e3c40",
        "x86_64-unknown-linux-gnu": "ff3bea5b8a7edd36bdcb0b628e559b84995d12cb7a8c4809eee4cf677d95c214",
    },
    "21.1.5": {
        "aarch64-unknown-linux-gnu": "3b90c0bcbe2d9b6502f82004ccc21dc4492de4a2707609e3f8d6f56f748097b9",
        "arm64-apple-darwin": "871239666d8c7c8ad8b9eef8ebbea5fb4c15f28712e2fb8e7cd9e7ae6343398c",
        "wasm32-unknown-emscripten": "0eca1f57cbbc004ce2cacf716779c255a20557421863254a6e986eed6e96b50b",
        "x86_64-apple-darwin": "9b43918c1f22172c62d7954a635e5b16b7d64651ef282c1898e5c85927c659e2",
        "x86_64-pc-windows-msvc": "ef5629312ac8f4cc6cf92120001b5ec6b95daa62dce522b9cee5897fa1427a3e",
        "x86_64-unknown-linux-gnu": "27c8e264eca64d85ffbcc216ee07e442abb0f79248cbf1a4a42449c55dfcda32",
    },
    "21.1.6": {
        "aarch64-unknown-linux-gnu": "8c9020593e85cdfd283f9f7e3e8254b081a5ac54033c91a5c32b99517c9680d0",
        "arm64-apple-darwin": "f8deb245fae46189f66cd380b9898f69ca0396251ef98567d37dab1e16e04521",
        "wasm32-unknown-emscripten": "d69c1c779b0d6aa10cd8ea1a2b3edecbe026ee17e802cea582d0106f92967ecf",
        "x86_64-apple-darwin": "5a66c269f79172d70263c04d63b2c7e78bc9369594d731fe92b535c6c0f8a654",
        "x86_64-pc-windows-msvc": "3f871dfade733943355b5a64a00b246ce97c612702fdd5657ae434341116519c",
        "x86_64-unknown-linux-gnu": "156be11cba9f98569787c14442caaf6164e93b64ef2ee652bc6bfa48316be2d3",
    },
    "21.1.7": {
        "aarch64-unknown-linux-gnu": "46963f2ecd58d8ecb5abfd06d4047a0c917d861744e8e6a2d35e2c8bfe383b9b",
        "arm64-apple-darwin": "814a3d352cae37ac852d4a79509ab7bf05a0b78b865647d7918e551116beb136",
        "wasm32-unknown-emscripten": "a25c82be76398a03cc5e24def9d205cff67c455f37e7a5ef8d05522eb1a11b01",
        "x86_64-apple-darwin": "f0e756d42b84e6d018ca83da6e54fa7861c559bb637362631a83ddbd3d2026a6",
        "x86_64-pc-windows-msvc": "2bcae8bc121698690c4e9d2e67bbfa384cb23b25e42aa471e08d53ee5f637928",
        "x86_64-unknown-linux-gnu": "ec81149f3fec96265f7b3d6e38cc20f8772c02c56318b3876e13a8c2c5eb6fea",
    },
    # FIXME: recompute once release assets stabilize
    # "21.1.8": {},
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
