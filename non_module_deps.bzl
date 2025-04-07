load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _non_module_deps_impl(mctx):
    http_archive(
        name = "llvm-raw",
        sha256 = "4d5ebbd40ce1e984a650818a4bb5ae86fc70644dec2e6d54e78b4176db3332e0",
        patch_args = ["-p1"],
        patches = [
            "//:267e293510ad0e273443bc1b6c3655f6307e3992.patch",
            "//:llvm.patch",
        ],
        strip_prefix = "llvm-project-20.1.1.src",
        urls = ["https://github.com/llvm/llvm-project/releases/download/llvmorg-20.1.1/llvm-project-20.1.1.src.tar.xz"],
    )

    http_archive(
        name = "llvm_zlib",
        build_file = "@llvm-raw//utils/bazel/third_party_build:zlib-ng.BUILD",
        sha256 = "e36bb346c00472a1f9ff2a0a4643e590a254be6379da7cddd9daeb9a7f296731",
        strip_prefix = "zlib-ng-2.0.7",
        urls = ["https://github.com/zlib-ng/zlib-ng/archive/refs/tags/2.0.7.zip"],
    )

    http_archive(
        name = "vulkan_headers",
        build_file = "@llvm-raw//utils/bazel/third_party_build:vulkan_headers.BUILD",
        sha256 = "19f491784ef0bc73caff877d11c96a48b946b5a1c805079d9006e3fbaa5c1895",
        strip_prefix = "Vulkan-Headers-9bd3f561bcee3f01d22912de10bb07ce4e23d378",
        urls = ["https://github.com/KhronosGroup/Vulkan-Headers/archive/9bd3f561bcee3f01d22912de10bb07ce4e23d378.tar.gz"],
    )

    http_archive(
        name = "llvm_zstd",
        build_file = "@llvm-raw//utils/bazel/third_party_build:zstd.BUILD",
        sha256 = "7c42d56fac126929a6a85dbc73ff1db2411d04f104fae9bdea51305663a83fd0",
        strip_prefix = "zstd-1.5.2",
        urls = ["https://github.com/facebook/zstd/releases/download/v1.5.2/zstd-1.5.2.tar.gz"],
    )


    return mctx.extension_metadata(
        reproducible = True,
        root_module_direct_deps = "all",
        root_module_direct_dev_deps = [],
    )

non_module_deps = module_extension(
    implementation = _non_module_deps_impl,
)
