
cc_binary(
    name = "main",
    srcs = ["main.cc"],
    copts = [
        "-nostdinc",
        "-std=c++23",
    ],
    linkopts = [
        "-nostdlib", # Implies "-nodefaultlibs", and "-nostartfiles".
        # "--sysroot=/dev/null",
        "-lc",
    ],
    deps = [
        "//lib:c++",
        "//lib:c",
        "//lib/libunwind",
        "//lib:Scrt1",
        "//compiler-rt-20.1.1.src/lib/builtins:builtins",

        # "//libc.so/x86_64:libc",
        # "//libc.so/x86_64:libdl",
        # "//libc.so/x86_64:libpthread",

        "//libc.so/aarch64:libc",
        "//libc.so/aarch64:libdl",
        "//libc.so/aarch64:libpthread",
        # "//compiler-rt-20.1.1.src/lib/builtins:crt",
    ],
)


# pub fn libcFullLinkFlags(target: std.Target) []const []const u8 {
#     // The linking order of these is significant and should match the order other
#     // c compilers such as gcc or clang use.
#     const result: []const []const u8 = switch (target.os.tag) {
#         .dragonfly, .freebsd, .netbsd, .openbsd => &.{ "-lm", "-lpthread", "-lc", "-lutil" },
#         // Solaris releases after 10 merged the threading libraries into libc.
#         .solaris, .illumos => &.{ "-lm", "-lsocket", "-lnsl", "-lc" },
#         .haiku => &.{ "-lm", "-lroot", "-lpthread", "-lc", "-lnetwork" },
#         .linux => switch (target.abi) {
#             .android, .androideabi, .ohos, .ohoseabi => &.{ "-lm", "-lc", "-ldl" },
#             else => &.{ "-lm", "-lpthread", "-lc", "-ldl", "-lrt", "-lutil" },
#         },
#         else => &.{},
#     };
#     return result;
# }
