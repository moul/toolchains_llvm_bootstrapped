load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")

directory(
    name = "sysroot",
    srcs = glob(["*/**"], exclude = glob([
        "System/Library/Frameworks/Ruby.framework/**",
        "System/Cryptexes/**",
        "System/iOSSupport/**",
        "System/Library/CoreServices/**",
        "System/Library/Perl/**",
        "System/Library/PrivateFrameworks/**",
        "usr/share/**",
        "usr/include/c++/**",
    ])),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "usr/include",
    path = "usr/include",
    parent = "sysroot",
    visibility = ["//visibility:public"],
)
