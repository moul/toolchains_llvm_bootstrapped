cc_library(
    name = "llvm_libc_headers",
    includes = [
        "lib/libcxx/libc",
    ],
    hdrs = glob([
        "lib/libcxx/libc/**",
    ]),
    visibility = ["//visibility:public"],
)
