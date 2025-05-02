load("@cc-toolchain//toolchain/stage2:cc_stage2_library.bzl", "cc_stage2_library")
load("@cc-toolchain//toolchain/stage2:cc_stage2_static_library.bzl", "cc_stage2_static_library")
load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")
load("@cc-toolchain//third_party/ziglang/zig:helpers.bzl", "glibc_includes", "glibc_headers", "linux_system_headers")

alias(
    name = "glibc_abilists",
    actual = "lib/libc/glibc/abilists",
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "glibc_init",
    copts = [
        # Normally, we would pass -nostdinc, but since we pass -nostdlibinc
        # from the stage2 toolchain args regarless, having them both cause a
        # warning about -nostdlibinc being ignored, so we duplicate the
        # -nostdlibinc and add -nobuiltininc to avoid the warning.
        #
        # -nostdinc = -nostdlibinc -nobuiltininc
        "-nostdlibinc",
        "-nobuiltininc",
    ],
    features = ["-default_compile_flags"],
    srcs = ["lib/libc/glibc/csu/init.c"],
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "glibc_abi_note",
    srcs = [
        "lib/libc/glibc/csu/abi-note.S",
    ],
    copts = [
        # Normally, we would pass -nostdinc, but since we pass -nostdlibinc
        # from the stage2 toolchain args regarless, having them both cause a
        # warning about -nostdlibinc being ignored, so we duplicate the
        # -nostdlibinc and add -nobuiltininc to avoid the warning.
        #
        # -nostdinc = -nostdlibinc -nobuiltininc
        "-nostdlibinc",
        "-nobuiltininc",
        "-Wa,--noexecstack",
    ],
    local_defines = [
        "_LIBC_REENTRANT",
        "MODULE_NAME=libc",
        "TOP_NAMESPACE=glibc",
        "ASSEMBLER",
    ],
    features = ["-default_compile_flags"],
    hdrs = glob(["lib/libc/glibc/**"]),
    includes = [
        "lib/libc/glibc/csu",
    ] + select({
        "@cc-toolchain//platforms/config:linux_x86_64": glibc_includes("x86_64"),
        "@cc-toolchain//platforms/config:linux_aarch64": glibc_includes("aarch64"),
    }),
    implementation_deps = [":gnu_libc_headers"],
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "glibc_start",
    srcs = select({
        "@cc-toolchain//platforms/config:linux_x86_64": ["lib/libc/glibc/sysdeps/x86_64/start.S"],
        "@cc-toolchain//platforms/config:linux_aarch64": ["lib/libc/glibc/sysdeps/aarch64/start.S"],
    }, no_match_error = "Unsupported platform"),
    copts = [
        # Normally, we would pass -nostdinc, but since we pass -nostdlibinc
        # from the stage2 toolchain args regarless, having them both cause a
        # warning about -nostdlibinc being ignored, so we duplicate the
        # -nostdlibinc and add -nobuiltininc to avoid the warning.
        #
        # -nostdinc = -nostdlibinc -nobuiltininc
        "-nostdlibinc",
        "-nobuiltininc",
        "-Wno-nonportable-include-path",
        "-Wa,--noexecstack",
        "-include",
        "$(location lib/libc/glibc/include/libc-modules.h)",
        "-DMODULE_NAME=libc",
        "-include",
        "$(location lib/libc/glibc/include/libc-symbols.h)",
    ],
    features = ["-default_compile_flags"],
    local_defines = [
        "_LIBC_REENTRANT",
        "MODULE_NAME=libc",
        "PIC",
        "SHARED",
        "TOP_NAMESPACE=glibc",
        "ASSEMBLER",
    ],
    additional_compiler_inputs = [
        "lib/libc/glibc/include/libc-modules.h",
        "lib/libc/glibc/include/libc-symbols.h",
    ],
    hdrs = glob(["lib/libc/glibc/**"]),

    # hdrs = glob([
    #     "lib/libc/glibc/**/*.h",
    # ], exclude = [
    #     "lib/libc/glibc/sysdeps/**",
    #     "lib/libc/glibc/include/**",
    # ]) + glob([
    #     "lib/libc/glibc/include/*.h",
    #     "lib/libc/glibc/include/*.h",
    # ])
    # + glob(
    #     [
    #         "lib/libc/glibc/sysdeps/unix/sysv/linux/x86_64/**",
    #         "lib/libc/glibc/sysdeps/x86_64/**",
    #         "lib/libc/glibc/sysdeps/unix/sysv/linux/generic/**",
    #         "lib/libc/glibc/sysdeps/unix/sysv/linux/include/**",
    #     ],
    #     allow_empty = True
    # ) + glob(
    #     [
    #         "lib/libc/glibc/sysdeps/unix/sysv/linux/*",
    #         "lib/libc/glibc/sysdeps/unix/sysv/linux/bits/**",
    #         "lib/libc/glibc/sysdeps/unix/sysv/linux/sys/**",
    #     ],
    #     allow_empty = True
    # )
    # + glob([
    #         # "lib/libc/glibc/sysdeps/nptl/**",
    #         "lib/libc/glibc/sysdeps/pthread/**",
    #         "lib/libc/glibc/sysdeps/unix/x86_64/**",
    #         # "lib/libc/glibc/sysdeps/x86_64/**",
    #         "lib/libc/glibc/sysdeps/generic/**",
    #     ],
    #     allow_empty = True
    # ),
    includes = select({
        "@cc-toolchain//platforms/config:linux_x86_64": glibc_includes("x86_64"),
        "@cc-toolchain//platforms/config:linux_aarch64": glibc_includes("aarch64"),
    }),
    implementation_deps = [
        ":linux_system_headers",
        ":gnu_libc_headers",
    ],
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "glibc_Scrt1",
    deps = [":glibc_start", ":glibc_init", ":glibc_abi_note"],
    visibility = ["//visibility:public"],
)

cc_stage2_static_library(
    name = "glibc_Scrt1.static",
    deps = [":glibc_Scrt1"],
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "linux_system_headers",
    hdrs = select({
        "@cc-toolchain//platforms/config:linux_x86_64": linux_system_headers("x86", as_glob = True),
        "@cc-toolchain//platforms/config:linux_aarch64": linux_system_headers("aarch64", as_glob = True),
        "@platforms//os:macos": [],
    }, no_match_error = "Unsupported platform"),
    includes = select({
        "@cc-toolchain//platforms/config:linux_x86_64": linux_system_headers("x86"),
        "@cc-toolchain//platforms/config:linux_aarch64": linux_system_headers("aarch64"),
        "@platforms//os:macos": [],
    }, no_match_error = "Unsupported platform"),
    visibility = ["//visibility:public"],
)

directory(
    name = "linux_system_headers_directory",
    srcs = select({
        "@cc-toolchain//platforms/config:linux_x86_64": linux_system_headers("x86", as_glob = True),
        "@cc-toolchain//platforms/config:linux_aarch64": linux_system_headers("aarch64", as_glob = True),
    }, no_match_error = "Unsupported platform"),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "linux_system_headers_arch_specific_directory",
    path = select({
        "@cc-toolchain//platforms/config:linux_x86_64": "lib/libc/include/x86-linux-any",
        "@cc-toolchain//platforms/config:linux_aarch64": "lib/libc/include/aarch64-linux-any",
    }, no_match_error = "Unsupported platform"),
    parent = ":linux_system_headers_directory",
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "linux_system_headers_generic_directory",
    path = "lib/libc/include/any-linux-any",
    parent = ":linux_system_headers_directory",
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "gnu_libc_headers",
    # order matters
    includes = select({
        "@cc-toolchain//platforms/config:linux_x86_64": glibc_headers("x86_64"),
        "@cc-toolchain//platforms/config:linux_aarch64": glibc_headers("aarch64"),
    }, no_match_error = "Unsupported platform"),
    hdrs = select({
        "@cc-toolchain//platforms/config:linux_x86_64": glibc_headers("x86_64", as_glob = True),
        "@cc-toolchain//platforms/config:linux_aarch64": glibc_headers("aarch64", as_glob = True),
    }, no_match_error = "Unsupported platform"),
    implementation_deps = select({
        "@platforms//os:macos": [],
        "@platforms//os:linux": [
            ":linux_system_headers",
        ],
    }),
    visibility = ["//visibility:public"],
)

# pub fn compilerRtOptMode(comp: Compilation) std.builtin.OptimizeMode {
#     if (comp.debug_compiler_runtime_libs) {
#         return comp.root_mod.optimize_mode;
#     }
#     const target = comp.root_mod.resolved_target.result;
#     switch (comp.root_mod.optimize_mode) {
#         .Debug, .ReleaseSafe => return target_util.defaultCompilerRtOptimizeMode(target),
#         .ReleaseFast => return .ReleaseFast,
#         .ReleaseSmall => return .ReleaseSmall,
#     }
# }

# pub fn defaultCompilerRtOptimizeMode(target: std.Target) std.builtin.OptimizeMode {
#     if (target.cpu.arch.isWasm() and target.os.tag == .freestanding) {
#         return .ReleaseSmall;
#     } else {
#         return .ReleaseFast;
#     }
# }

cc_stage2_library(
    # glibc_c_nonshared
    name = "c_nonshared",
    copts = [
        "-std=gnu11",
        "-fgnu89-inline",
        "-fmerge-all-constants",
        "-frounding-math",
        "-Wno-unsupported-floating-point-opt", # For targets that don't support -frounding-math.
        "-fno-common",
        "-fmath-errno",
        "-ftls-model=initial-exec",
        "-Wno-ignored-attributes",
        "-Qunused-arguments",

        "-Wno-nonportable-include-path",

        "-include",
        "$(location lib/libc/glibc/include/libc-modules.h)",
        "-include",
        "$(location lib/libc/glibc/include/libc-symbols.h)",
    ],
    local_defines = [
        "NO_INITFINI",
        "_LIBC_REENTRANT",
        "MODULE_NAME=libc",
        # "PIC",
        "LIBC_NONSHARED=1",
        "TOP_NAMESPACE=glibc",
    ] + select({
        "@cc-toolchain//platforms/config:linux_x86_64": [
            "CAN_USE_REGISTER_ASM_EBP",
        ],
        "//conditions:default": [],
    }),
    hdrs = glob(["lib/libc/glibc/**"]),
    includes = [
        "lib/libc/glibc/csu",
    ] + select({
        "@cc-toolchain//platforms/config:linux_x86_64": glibc_includes("x86_64"),
        "@cc-toolchain//platforms/config:linux_aarch64": glibc_includes("aarch64"),
    }),
    srcs = [
        "lib/libc/glibc/stdlib/atexit.c",
        "lib/libc/glibc/stdlib/at_quick_exit.c",
        "lib/libc/glibc/sysdeps/pthread/pthread_atfork.c",
        "lib/libc/glibc/debug/stack_chk_fail_local.c",

        # if libc <= 2.32
        # libc_nonshared.a redirected stat functions to xstat until glibc 2.33,
        # when they were finally versioned like other symbols.
        
        "lib/libc/glibc/io/stat-2.32.c",
        "lib/libc/glibc/io/fstat-2.32.c",
        "lib/libc/glibc/io/lstat-2.32.c",
        "lib/libc/glibc/io/stat64-2.32.c",
        "lib/libc/glibc/io/fstat64-2.32.c",
        "lib/libc/glibc/io/lstat64-2.32.c",
        "lib/libc/glibc/io/fstatat-2.32.c",
        "lib/libc/glibc/io/fstatat64-2.32.c",
        "lib/libc/glibc/io/mknodat-2.32.c",
        "lib/libc/glibc/io/mknod-2.32.c",

        # if libc <= 2.33
        # __libc_start_main used to require statically linked init/fini callbacks
        # until glibc 2.34 when they were assimilated into the shared library.
        "lib/libc/glibc/csu/elf-init-2.33.c",
    ],
    additional_compiler_inputs = [
        "lib/libc/glibc/include/libc-modules.h",
        "lib/libc/glibc/include/libc-symbols.h",
    ],
    implementation_deps = select({
        "@platforms//os:macos": [],
        "@platforms//os:linux": [
            ":linux_system_headers",
        ],
    }) + [
        ":gnu_libc_headers",
    ],
    visibility = ["//visibility:public"],
)

directory(
    name = "glibc_headers_directory",
    srcs = select({
        "@cc-toolchain//platforms/config:linux_x86_64": glibc_headers("x86_64", as_glob = True),
        "@cc-toolchain//platforms/config:linux_aarch64": glibc_headers("aarch64", as_glob = True),
    }, no_match_error = "Unsupported platform"),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "glibc_headers_arch_specific_directory",
    path = select({
        "@cc-toolchain//platforms/config:linux_x86_64": "lib/libc/include/x86_64-linux-gnu",
        "@cc-toolchain//platforms/config:linux_aarch64": "lib/libc/include/aarch64-linux-gnu",
    }, no_match_error = "Unsupported platform"),
    parent = ":glibc_headers_directory",
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "glibc_headers_generic_directory",
    path = "lib/libc/include/generic-glibc",
    parent = ":glibc_headers_directory",
    visibility = ["//visibility:public"],
)

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
