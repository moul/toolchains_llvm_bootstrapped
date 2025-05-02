
load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")

## 

directory(
    name = "builtin_headers_files",
    srcs = glob(["lib/clang/20/include/**"]),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "builtin_headers_include_directory",
    path = "lib/clang/20/include",
    parent = ":builtin_headers_files",
    visibility = ["//visibility:public"],
)

##

# Convenient exports
exports_files([
    "bin/clang",
    "bin/clang++",
    "bin/clang-cpp",
    "bin/lld",
    "bin/ld.lld",
    "bin/ld64.lld",
    "bin/wasm-ld",
    "bin/llvm-ar",
    "bin/llvm-as",
    "bin/llvm-libtool-darwin",
    "bin/llvm-nm",
    "bin/llvm-objcopy",
    "bin/llvm-strip",
    # "bin/clang-tidy",
    # "bin/clang-format",
    "bin/clangd",
    # "bin/llvm-symbolizer",
    # "bin/llvm-profdata",
    # "bin/llvm-cov",
    # "bin/llvm-dwp",
    # "bin/llvm-objdump",
])
