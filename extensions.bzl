"""Module extension for downloading prebuilt libomp."""

load(":repositories.bzl", "omp_repository")

_DEFAULT_VERSION = "21.1.8"

# sha256 checksums keyed by llvm version -> target triple
# append new versions here as artifacts are built
_CHECKSUMS = {
    "20.1.0": {
        "aarch64-unknown-linux-gnu": "98a40da2d80a8bd35aa91eff63ecfb7ae6856bcf27d405c76c83707b4b895286",
        "arm64-apple-darwin": "a68841f3b0f6f839988320f5137ba59aa744ad1518076ea065b92fdb8f341980",
        "wasm32-unknown-emscripten": "1651780f40cb0f0083c1bbb8e6136be424ac258bbc4e327991092b48c820f4f6",
        "x86_64-apple-darwin": "3c4aacc618bfb11c82afe8607940e9f64451b28e2f13b156798d486c5ebb754c",
        "x86_64-pc-windows-msvc": "e8184d3b6cedbae8b2f40c979a68bab842ec8067f5c3f457300d55e8bfd679e7",
        "x86_64-unknown-linux-gnu": "d2e3dae0905c4b5653e104059c4d6b6da0b746c79d361c06fda807af1de07f09",
    },
    "20.1.1": {
        "aarch64-unknown-linux-gnu": "b5bd7f1975d11b6da00387650b5227366615deb2e5328f9c93bb552429455ec3",
        "arm64-apple-darwin": "c25bd9f50198c229fa967e3e9f0bb18f553df65e17b3df685fac6d917423c60b",
        "wasm32-unknown-emscripten": "2db15e3f84dd3792d951fe5a57eb6c972326838a055ceafe006d174247c9aba8",
        "x86_64-apple-darwin": "938f0a29f516606e18d317a3b2f42482dbdd1e326be74ac0fe65914ed184b4b8",
        "x86_64-pc-windows-msvc": "1d64c8d739cad305e1a2ed7a51dcfc1e67a45c4abec6f5ac6ea05230dcbe357b",
        "x86_64-unknown-linux-gnu": "a1f3e71888ff4767a8418f8e19c1d1f611afd5505c00149d9a1995a0673d8f7b",
    },
    "20.1.2": {
        "aarch64-unknown-linux-gnu": "6ac02741a29ab2c67ec8c723eb98f195c110ce21c3ebd94c6bf2293476e4bcb7",
        "arm64-apple-darwin": "3fc6386ec232648ead23997b42b7ced35f147b4e0bcf5b90b6f01ae3413dc13d",
        "wasm32-unknown-emscripten": "51c8149d39cbbaed73eaad936c2f46361739aadf792a9d87b50ecdcd4d079a33",
        "x86_64-apple-darwin": "11d462fe63acc25f7c4e6d08b0cf3e309340f7b6906c71599824b05fa6488d5c",
        "x86_64-pc-windows-msvc": "61ed6ad0167c565d4cb9925dd1a3815c81deb6e480c1428f45d6e104c0efdc4f",
        "x86_64-unknown-linux-gnu": "1651062ac449ea3513ebfeb2dc2718fd38525c182fa5043153f0bcc098c9337f",
    },
    "20.1.3": {
        "aarch64-unknown-linux-gnu": "671acdfc193a84c6a38eb2aff8edecfe02c162b7052810c3d0bf056d85e246d4",
        "arm64-apple-darwin": "5c5adfd947cdbbf1d6fc5ed1458fdff9619b3d2febea6fd0e15f2a40c36fca2b",
        "wasm32-unknown-emscripten": "bea4debf43679a5c3585d7d37b3d97cb46687c21fd27d393793a6ae2d5ab0cca",
        "x86_64-apple-darwin": "740e1c4fbc0af4934fe36ecb21253b54e39a1942c161ec45b35d22aff92e12a9",
        "x86_64-pc-windows-msvc": "b8f378fd318d45e3d376b9548110924cac84b1c8a13bd3527d15c22dbea4a20f",
        "x86_64-unknown-linux-gnu": "07560bc3b7e19b6f6823e5145a39609035a03fe49d399b18a45658538c7fc327",
    },
    "20.1.4": {
        "aarch64-unknown-linux-gnu": "aaa049fd33948bd17cc334acf682e14e51a62433c1f0f502a23eee3d6d7eb9ba",
        "arm64-apple-darwin": "995a045c4123eb186add4337c21c8b94e8dd236559a66b5c07d2b00a1dd7755c",
        "wasm32-unknown-emscripten": "9acfa554b9648ce15e4ab03526f240cccfb157582cead9dad2db0b2c818fc55f",
        "x86_64-apple-darwin": "689e8fdcd4bb05cd2d0821fca3291b772fa58f578b0a6ca75ef3de05bf1b5ac7",
        "x86_64-pc-windows-msvc": "158e2171fe2aa9cbffbaca6eb3cbd1f3dd9a1dcea17393de339658b9e072dbd6",
        "x86_64-unknown-linux-gnu": "cfec89e41f8a4c548ee355cf724b906df02391783cc36dfc56fef775fe74d1fb",
    },
    "20.1.5": {
        "aarch64-unknown-linux-gnu": "9ac98dc3fe16da903536cb3aa7d058fda3c79468d7abc89074751b0e7aa7dcc9",
        "arm64-apple-darwin": "c50d4a8853477bcebf03aa168ead5d7ade669a364f503fbd60cee8bdbe05ef7c",
        "wasm32-unknown-emscripten": "ee420674cec98731cbe9c6b81ad5d91d456a4332dedcffb0ac40d179bd0fb6f2",
        "x86_64-apple-darwin": "dbb1569cf6dbb91db68ce7f703daad7f18a596e05502cc777844d4554e90efbc",
        "x86_64-pc-windows-msvc": "cd33ded49dec49f38753f48a2f6ae82f62b1b54e1ce668dba16568c3f0119c9f",
        "x86_64-unknown-linux-gnu": "159ca92613b85c210c685b0b5d2614c40b438c7a1fa2609468508ab385f37166",
    },
    "20.1.6": {
        "aarch64-unknown-linux-gnu": "4ecba2c3172347301b653e29f87327ad91baaccd7007ecad138ade69e6023e57",
        "arm64-apple-darwin": "b339a0d55652a4e72aa38ad53bff422f1a9eb44c5de8ee803ead5618ab2fc76f",
        "wasm32-unknown-emscripten": "0f298d35f968a690ea72a62e1b204a06ac33d9e4356d92d8e7724c641811c874",
        "x86_64-apple-darwin": "ba590e0f6ced9f461b5ea076e5012fabdd3fb0687ec8670fcb714d6845763937",
        "x86_64-pc-windows-msvc": "8972e4b58740c77d875c65836139df8bc4c5c4f30c8ef4c03632e8751d8607aa",
        "x86_64-unknown-linux-gnu": "4972cc7c42f5c7e84950342fb376ad8d9633062c424dbea5a09b326a63df059e",
    },
    "20.1.7": {
        "aarch64-unknown-linux-gnu": "d4191c73806062ff7f07edce1728f166a3fce3fc23511b8f827431c674a80759",
        "arm64-apple-darwin": "54ee316b974a75a293ff595ccaa6f42611678d4e0c00a61d68c6dc12ea2e55cd",
        "wasm32-unknown-emscripten": "679db7a3e902615c47b881b6849f1e6c71b8d4b11a8b3af60c69ba92fe878589",
        "x86_64-apple-darwin": "87d3b81c9af78407c1e46760df594ec193be93c8c329a526ba82207679db2d53",
        "x86_64-pc-windows-msvc": "31634afdb80e8ed12633a8ecd3fcb57d86c5027a14c4c04cb4d4d7ef99a713a7",
        "x86_64-unknown-linux-gnu": "fc016f0b3432de1979ee933bdbf7109a06181d1a141dd14646976a0994623636",
    },
    "20.1.8": {
        "aarch64-unknown-linux-gnu": "528fe12f0b582760509eaa291e93fffef73c2fdbeb52e01ea87ef57a66a63ec6",
        "arm64-apple-darwin": "510ef93a911b240b9cbdae6ff3a8bcf501bc8e6fd86685066243d60bd2546f74",
        "wasm32-unknown-emscripten": "f9681be14e0b9fb2519b0566b6f60e6e146e8fbbfbee8b13a937cdcc46c91ad3",
        "x86_64-apple-darwin": "056ad41d72fd76a88d5fd970ef6cb1e764abdc3fe2170667c1b889bf697d77b4",
        "x86_64-pc-windows-msvc": "f2f99bbd6087b6af31f02f2f9040466bd8d5686336983d6a53fd6aabf93cacf2",
        "x86_64-unknown-linux-gnu": "62dbbcb5b0dc8da89b338d8e99c3a41658ac128ecd9c4e9f29748f2b8bc37f69",
    },
    "21.1.0": {
        "aarch64-unknown-linux-gnu": "d2018f00f9448626b5e1ca4d94ef6f80ae487fbba1ca3a884e0621339c1d6062",
        "arm64-apple-darwin": "e14f7dac48f3482c1c5aba559f573458ead5ad2ec0919c85bfe708a1e5906568",
        "wasm32-unknown-emscripten": "53de8172bf0d93f6dfd69035e7ad9a2b0d61a2ca7c744307c9eee2f63fcdfb25",
        "x86_64-apple-darwin": "683c61b8b8b59587ebd071196a5cf02f9daa88f091f0578df016845cf99fcff5",
        "x86_64-pc-windows-msvc": "98afef809111f17432e30db2e3e77f22c450022a490f726d884d4918a5b2b441",
        "x86_64-unknown-linux-gnu": "94e233c35315838965f6d566851bfb3b2447b9d8cb0f4b3b438e2fff2ff50263",
    },
    "21.1.1": {
        "aarch64-unknown-linux-gnu": "31cf9277f0e264377d76bb7ff86d7a8cb397e3f96388e71423f16f0a63726901",
        "arm64-apple-darwin": "73704a97a1a0e862b7042586d646b553b8a0ae934adcabee4ccc1ebd95af00fe",
        "wasm32-unknown-emscripten": "61880fbef9ab603011bac9eca558385b4d1b66331d81ef8406267d5e4f78c766",
        "x86_64-apple-darwin": "16580de71c767a8e400354f42d8f440a293113ea4c98baf29a873395950f88c8",
        "x86_64-pc-windows-msvc": "2e95315baa42f299b7375b43662bfc9d22e301dcb26e7f2c5c46670c4bf0d663",
        "x86_64-unknown-linux-gnu": "ed5fcbe44acd82b9d8c95b8f6b5b272ab000eb03e00d9c886de502d9387f1440",
    },
    "21.1.2": {
        "aarch64-unknown-linux-gnu": "ed96e3d20f81e492dcf30e33ba87b673847ca95abe62329be260a5ff5c4fb9a7",
        "arm64-apple-darwin": "b974b352ebf04012095483894db54285e010160db17a4fcbe20f26bba2192af5",
        "wasm32-unknown-emscripten": "74ecae41fdb25438c3378033b9b08a4cf0a39cf894a22d29cddbb1f023e78a46",
        "x86_64-apple-darwin": "91ce927867cbbade135a7bd5ade8556aa72151fc757d43ce7e586062a77072c8",
        "x86_64-pc-windows-msvc": "ed7e73d8f0af19e788afd5e31301e96e0fea9c404787e9e532c7cce546917dff",
        "x86_64-unknown-linux-gnu": "964aea32c131e3bd2336c8b98c28fe11181b977eb34be66211c4a3cc7c69a583",
    },
    "21.1.3": {
        "aarch64-unknown-linux-gnu": "e22f3b5b84ad58d077774f50881ffa9cedb2568fa85beb850d31b923ec3f14bd",
        "arm64-apple-darwin": "b83f1f3564a237f7e8720e22e173c117e0d62a30cb4ca26bc29cf0aac2784e56",
        "wasm32-unknown-emscripten": "9c20a541efa8e826b9cbff92ed63cafe1ac1ee52b7ae0c54f15ab1c70e2ce98b",
        "x86_64-apple-darwin": "93ff40f74c0a2f228ada97a5fe5bea2bb6744ea10f3b3087b3bfc2c90cd4157f",
        "x86_64-pc-windows-msvc": "808b0cb4a8ca7f9c9475f72ca16446266285761f0971c3703a8267b00a15aeca",
        "x86_64-unknown-linux-gnu": "0bab712781078d4c2e8f3982d7bf87a1493d8bcf580a3acb7090e6025da58970",
    },
    "21.1.4": {
        "aarch64-unknown-linux-gnu": "1aeb99b6d9c7e58030a7f5ccd54568ff4c5a1210d3e6d99b9da2048dd970167c",
        "arm64-apple-darwin": "227343f1833a237824e5f8b4cf9193286c2738f9d4c820e7e0763242912825d5",
        "wasm32-unknown-emscripten": "6206c81ff195ff696ee06cd659d85224d90ca726b271a6c728f6bbbdaa56e675",
        "x86_64-apple-darwin": "0415edc7792f64dbf0b3c2f6f011af7e381352d34214c41db3e7b97eb8afc097",
        "x86_64-pc-windows-msvc": "3e0e50ee93e7231200c79a83f387300e464191f1809bd657c317105803987823",
        "x86_64-unknown-linux-gnu": "da27d1d4c34d84ab82361054238240b0eef965392cc0e8d8366c253f04c09863",
    },
    "21.1.5": {
        "aarch64-unknown-linux-gnu": "9d0b5c2f082821e5b196269c574dc9ef992404adca114c3938da992a303e75fc",
        "arm64-apple-darwin": "6310e1f8a9d9233568e5485a3a6795bfa7beb87b8169e6ac87bc04d46004f17d",
        "wasm32-unknown-emscripten": "8de2a45a7b591661742b180c32c9246550abb6712f29dfc4416615273a7207fb",
        "x86_64-apple-darwin": "3e42e264156bd7b7e54520ebc289be683095392b68b897ec126786a8ef444bf9",
        "x86_64-pc-windows-msvc": "5c504daebad9942d259fbc353b0593af9af6dbc62a8b3e5e73ea3335eb39aece",
        "x86_64-unknown-linux-gnu": "3025ba3c4943ec471397d824b9a31ec889526c1fefdfc6ab71776e39fe8eb136",
    },
    "21.1.6": {
        "aarch64-unknown-linux-gnu": "4098c0852f9237a6e9f6ef9faca7ed7ffd45e931e46917adcce3b4ab1031ca4b",
        "arm64-apple-darwin": "139729bd077afbe971581a11c610efdc39030b60794605c4f52abedbcff62a88",
        "wasm32-unknown-emscripten": "6bca50167a1e85a0d9fcae23fb836a767ecd227a59e23ada57c9e43dbe339af5",
        "x86_64-apple-darwin": "228403763c977d2e1d858c40c4170f5fc6159d3cb02d680a270f48aef8af9cd3",
        "x86_64-pc-windows-msvc": "9c09e8247562ef370c117a6fa7abe28b489e09612a90c63f8f4eed34e746f464",
        "x86_64-unknown-linux-gnu": "0401cded00408ee311686252c10836639e2628bdfbecf91c2769d5d37a47f35c",
    },
    "21.1.7": {
        "aarch64-unknown-linux-gnu": "2e31dbd3eb5d2139b9da17ddab974482bc491c1412336c1b4ce1dc22382ee075",
        "arm64-apple-darwin": "10401e4e67a9cd0f2c99478e781fc5611abb4206f0d7194c00264292ee2f77b7",
        "wasm32-unknown-emscripten": "94b06b9b97265c25b0d574f273e03c2c31d495787e9ad2b3398779075496bc60",
        "x86_64-apple-darwin": "c54bbdb5f69faffdbcddfa8d04b881b2202be4c8276064aff7acbb8e1b67b474",
        "x86_64-pc-windows-msvc": "c8517dedc693d74cf228e1912078ffd97c54e5e017944086b14c55898fc64ae9",
        "x86_64-unknown-linux-gnu": "afc2a2b51f13734777ed5ef2bb20949a9613b50f649b03a439f7e4fd1ffbb2a8",
    },
    "21.1.8": {
        "aarch64-unknown-linux-gnu": "8d1dd488883ad6fdb33cb723e447e88bdb01e3c29bc5219d8ece29bfc6ebd37a",
        "arm64-apple-darwin": "38f9292f7e887faa3e042538782533c8d9f122038fdab1e7a615014942ddae41",
        "wasm32-unknown-emscripten": "1ccce37a64b1a72e50b490f882512ddc59f4b6f06c06ae5b4387571798860da4",
        "x86_64-apple-darwin": "a88d3dac6dd8508ae1bee25d767a7c71e31d330faf9d03152e2b1b05e6f948cc",
        "x86_64-pc-windows-msvc": "632a62b1f45d2e4d5bfb0856459e7173e20bbda311ab0ec7b6b57241ea2c0b78",
        "x86_64-unknown-linux-gnu": "83d67876105e73dd55fd61a0f35832b9271ca05a88c61cbf16670a1f1c47a2c1",
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
