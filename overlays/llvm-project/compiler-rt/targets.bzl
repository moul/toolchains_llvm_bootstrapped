load("@rules_cc//cc:defs.bzl", "cc_library")

"""
Helper functions for defining targets.
"""
def atomic_helper_cc_library(name, pat, size, model):
    cc_library(
        name = name,
        srcs = ["lib/builtins/aarch64/lse.S"],
        copts = [
            "-nostdinc",
        ],
        local_defines = [
            "L_{}".format(pat),
            "SIZE={}".format(size),
            "MODEL={}".format(model),
        ],
        hdrs = [
            "lib/builtins/assembly.h",
        ],
        includes = ["lib/builtins"],
        deps = [
            "@zig-srcs//:builtin_headers",
        ],
    )
    return name
