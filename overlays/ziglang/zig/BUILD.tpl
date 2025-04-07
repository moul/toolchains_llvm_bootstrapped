load("@cc-toolchain//toolchain/bootstrap:cc_bootstrap_library.bzl", "cc_bootstrap_library")
load("@cc-toolchain//toolchain/bootstrap:cc_bootstrap_static_library.bzl", "cc_bootstrap_static_library")
load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")
load("@cc-toolchain//overlays/ziglang/zig:helpers.bzl", "glibc_includes", "libc_headers", "linux_system_headers")

alias(
    name = "glibc_abilists",
    actual = "lib/libc/glibc/abilists",
    visibility = ["//visibility:public"],
)

cc_bootstrap_library(
    name = "init",
    copts = [
        "-nostdinc",
    ],
    features = ["-default_compile_flags"],
    srcs = ["lib/libc/glibc/csu/init.c"],
    visibility = ["//visibility:public"],
)

cc_bootstrap_library(
    name = "abi_note",
    srcs = [
        "lib/libc/glibc/csu/abi-note.S",
    ],
    copts = [
        "-nostdinc",
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
        "@cc-toolchain//constraint:linux_x86_64": glibc_includes("x86_64"),
        "@cc-toolchain//constraint:linux_aarch64": glibc_includes("aarch64"),
    }),
    implementation_deps = [":c"],
    visibility = ["//visibility:public"],
)

cc_bootstrap_library(
    name = "start",
    srcs = select({
        "@cc-toolchain//constraint:linux_x86_64": ["lib/libc/glibc/sysdeps/x86_64/start.S"],
        "@cc-toolchain//constraint:linux_aarch64": ["lib/libc/glibc/sysdeps/aarch64/start.S"],
    }, no_match_error = "Unsupported platform"),
    copts = [
        "-nostdinc",
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
        "@cc-toolchain//constraint:linux_x86_64": glibc_includes("x86_64"),
        "@cc-toolchain//constraint:linux_aarch64": glibc_includes("aarch64"),
    }),
    implementation_deps = [
        ":linux_system_headers",
        ":c",
    ],
    visibility = ["//visibility:public"],
)

cc_bootstrap_library(
    name = "Scrt1",
    deps = [":start", ":init", ":abi_note"],
    visibility = ["//visibility:public"],
)

cc_bootstrap_static_library(
    name = "Scrt1.static",
    deps = [":Scrt1"],
    visibility = ["//visibility:public"],
)

cc_bootstrap_library(
    name = "builtin_headers",
    includes = [
        "lib/include",
    ],
    hdrs = glob(["lib/include/**"]),
    visibility = ["//visibility:public"],
)

directory(
    name = "builtin_headers_directory",
    srcs = glob([
        "lib/include/**",
    ]),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "include",
    path = "lib/include",
    parent = ":builtin_headers_directory",
    visibility = ["//visibility:public"],
)

cc_bootstrap_library(
    name = "linux_system_headers",
    hdrs = select({
        "@cc-toolchain//constraint:linux_x86_64": linux_system_headers("x86", as_glob = True),
        "@cc-toolchain//constraint:linux_aarch64": linux_system_headers("aarch64", as_glob = True),
    }, no_match_error = "Unsupported platform"),
    includes = select({
        "@cc-toolchain//constraint:linux_x86_64": linux_system_headers("x86"),
        "@cc-toolchain//constraint:linux_aarch64": linux_system_headers("aarch64"),
    }, no_match_error = "Unsupported platform"),
    visibility = ["//visibility:public"],
)

directory(
    name = "linux_system_headers_directory",
    srcs = select({
        "@cc-toolchain//constraint:linux_x86_64": linux_system_headers("x86", as_glob = True),
        "@cc-toolchain//constraint:linux_aarch64": linux_system_headers("aarch64", as_glob = True),
    }, no_match_error = "Unsupported platform"),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "linux_system_headers_arch_specific_directory",
    path = select({
        "@cc-toolchain//constraint:linux_x86_64": "lib/libc/include/x86-linux-any",
        "@cc-toolchain//constraint:linux_aarch64": "lib/libc/include/aarch64-linux-any",
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

cc_bootstrap_library(
    name = "c",
    # order matters
    includes = select({
        "@cc-toolchain//constraint:linux_x86_64": libc_headers("x86_64"),
        "@cc-toolchain//constraint:linux_aarch64": libc_headers("aarch64"),
    }, no_match_error = "Unsupported platform"),
    hdrs = select({
        "@cc-toolchain//constraint:linux_x86_64": libc_headers("x86_64", as_glob = True),
        "@cc-toolchain//constraint:linux_aarch64": libc_headers("aarch64", as_glob = True),
    }, no_match_error = "Unsupported platform"),
    implementation_deps = [
        ":linux_system_headers",
    ],
    visibility = ["//visibility:public"],
)

directory(
    name = "libc_headers_directory",
    srcs = select({
        "@cc-toolchain//constraint:linux_x86_64": libc_headers("x86_64", as_glob = True),
        "@cc-toolchain//constraint:linux_aarch64": libc_headers("aarch64", as_glob = True),
    }, no_match_error = "Unsupported platform"),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "libc_headers_arch_specific_directory",
    path = select({
        "@cc-toolchain//constraint:linux_x86_64": "lib/libc/include/x86_64-linux-gnu",
        "@cc-toolchain//constraint:linux_aarch64": "lib/libc/include/aarch64-linux-gnu",
    }, no_match_error = "Unsupported platform"),
    parent = ":libc_headers_directory",
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "libc_headers_generic_directory",
    path = "lib/libc/include/generic-glibc",
    parent = ":libc_headers_directory",
    visibility = ["//visibility:public"],
)

cc_bootstrap_library(
    name = "c++",
    defines = [
        # "_LIBCPP_HAS_NO_THREADS",
        "NDEBUG",
        "_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_NONE", # select based on compilation_mode
        "_LIBCPP_BUILDING_LIBRARY",
        "_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS",
        "_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER",
        "_LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS",
        "LIBCXX_BUILDING_LIBCXXABI",

        # See libcxx/include/__algorithm/pstl_backends/cpu_backends/backend.h
        # for potentially enabling some fancy features here, which would
        # require corresponding changes in libcxx.zig, as well as
        # Compilation.addCCArgs. This option makes it use serial backend which
        # is simple and works everywhere.
        "_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS",
        "_LIBCPP_PSTL_BACKEND_SERIAL",
        "_LIBCPP_ABI_VERSION=1",
        "_LIBCPP_ABI_NAMESPACE=__1",

        # "_LIBCPP_HAS_MUSL_LIBC"
        # if (target.isGnuLibC()) {
        #   glibc 2.16 introduced aligned_alloc
        #   if (target.os.versionRange().gnuLibCVersion().?.order(.{ .major = 2, .minor = 16, .patch = 0 }) == .lt) {
        #     try cflags.append("-D_LIBCPP_HAS_NO_LIBRARY_ALIGNED_ALLOCATION");
        #   }
        # }
    ],
    features = ["-default_compile_flags"],
    copts = [
        "-nostdinc",
        "-std=c++23",
        "-Wno-user-defined-literals",
        "-Wno-covered-switch-default",
        "-Wno-suggest-override",
        "-fvisibility=hidden",
        "-fvisibility-inlines-hidden",
        "-faligned-allocation",
    ],
    includes = [
        "lib/libcxx/include",
        "lib/libcxx/src",
        "lib/libcxxabi/include",
        "lib/libcxxabi/src",
    ],
    hdrs = glob([
        "lib/libcxx/include/**",
        "lib/libcxxabi/include/**",
    ]),
    textual_hdrs = glob([
        "lib/libcxx/src/**/*.h",
        "lib/libcxx/src/**/*.ipp",
        "lib/libcxxabi/src/**/*.h",
        "lib/libcxxabi/src/**/*.def",
    ]),
    srcs = [
        "lib/libcxx/src/algorithm.cpp",
        "lib/libcxx/src/any.cpp",
        "lib/libcxx/src/bind.cpp",
        "lib/libcxx/src/call_once.cpp",
        "lib/libcxx/src/charconv.cpp",
        "lib/libcxx/src/chrono.cpp",
        "lib/libcxx/src/error_category.cpp",
        "lib/libcxx/src/exception.cpp",
        "lib/libcxx/src/expected.cpp",
        "lib/libcxx/src/filesystem/directory_entry.cpp",
        "lib/libcxx/src/filesystem/directory_iterator.cpp",
        "lib/libcxx/src/filesystem/filesystem_clock.cpp",
        "lib/libcxx/src/filesystem/filesystem_error.cpp",
        # omit int128_builtins.cpp because it provides __muloti4 which is already provided
        # by compiler_rt and crashes on Windows x86_64: https://github.com/ziglang/zig/issues/10719
        # "lib/libcxx/src/filesystem/int128_builtins.cpp",
        "lib/libcxx/src/filesystem/operations.cpp",
        "lib/libcxx/src/filesystem/path.cpp",
        "lib/libcxx/src/fstream.cpp",
        "lib/libcxx/src/functional.cpp",
        "lib/libcxx/src/hash.cpp",
        "lib/libcxx/src/ios.cpp",
        "lib/libcxx/src/ios.instantiations.cpp",
        "lib/libcxx/src/iostream.cpp",
        "lib/libcxx/src/legacy_pointer_safety.cpp",
        "lib/libcxx/src/locale.cpp",
        "lib/libcxx/src/memory.cpp",
        "lib/libcxx/src/memory_resource.cpp",
        "lib/libcxx/src/new.cpp",
        "lib/libcxx/src/new_handler.cpp",
        "lib/libcxx/src/new_helpers.cpp",
        "lib/libcxx/src/optional.cpp",
        "lib/libcxx/src/ostream.cpp",
        "lib/libcxx/src/print.cpp",
        # "lib/libcxx/src/pstl/libdispatch.cpp",
        "lib/libcxx/src/random.cpp",
        "lib/libcxx/src/random_shuffle.cpp",
        "lib/libcxx/src/regex.cpp",
        "lib/libcxx/src/ryu/d2fixed.cpp",
        "lib/libcxx/src/ryu/d2s.cpp",
        "lib/libcxx/src/ryu/f2s.cpp",
        "lib/libcxx/src/stdexcept.cpp",
        "lib/libcxx/src/string.cpp",
        "lib/libcxx/src/strstream.cpp",
        # "lib/libcxx/src/support/ibm/mbsnrtowcs.cpp",
        # "lib/libcxx/src/support/ibm/wcsnrtombs.cpp",
        # "lib/libcxx/src/support/ibm/xlocale_zos.cpp",
        # "lib/libcxx/src/support/win32/locale_win32.cpp",
        # "lib/libcxx/src/support/win32/support.cpp",
        "lib/libcxx/src/system_error.cpp",
        "lib/libcxx/src/typeinfo.cpp",
        "lib/libcxx/src/valarray.cpp",
        "lib/libcxx/src/variant.cpp",
        "lib/libcxx/src/vector.cpp",
        "lib/libcxx/src/verbose_abort.cpp",
    ] + [
        "lib/libcxxabi/src/abort_message.cpp",
        "lib/libcxxabi/src/cxa_aux_runtime.cpp",
        "lib/libcxxabi/src/cxa_default_handlers.cpp",
        "lib/libcxxabi/src/cxa_demangle.cpp",
        "lib/libcxxabi/src/cxa_exception.cpp",
        "lib/libcxxabi/src/cxa_exception_storage.cpp",
        "lib/libcxxabi/src/cxa_guard.cpp",
        "lib/libcxxabi/src/cxa_handlers.cpp",
        # "lib/libcxxabi/src/cxa_noexception.cpp",
        "lib/libcxxabi/src/cxa_personality.cpp",
        "lib/libcxxabi/src/cxa_thread_atexit.cpp",
        "lib/libcxxabi/src/cxa_vector.cpp",
        "lib/libcxxabi/src/cxa_virtual.cpp",
        "lib/libcxxabi/src/fallback_malloc.cpp",
        "lib/libcxxabi/src/private_typeinfo.cpp",
        "lib/libcxxabi/src/stdlib_exception.cpp",
        "lib/libcxxabi/src/stdlib_new_delete.cpp",
        "lib/libcxxabi/src/stdlib_stdexcept.cpp",
        "lib/libcxxabi/src/stdlib_typeinfo.cpp",
    ],
    implementation_deps = [
        ":linux_system_headers",
        ":builtin_headers",
        ":c",
    ],
    visibility = ["//visibility:public"],
)

directory(
    name = "libcxx_headers_directory",
    srcs = glob([
        "lib/libcxx/include/**",
        "lib/libcxxabi/include/**",
    ]),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "libcxx/include",
    path = "lib/libcxx/include",
    parent = ":libcxx_headers_directory",
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "libcxxabi/include",
    path = "lib/libcxxabi/include",
    parent = ":libcxx_headers_directory",
    visibility = ["//visibility:public"],
)

## libunwind

cc_bootstrap_library(
    name = "libunwind",
    copts = [
        "-nostdinc",
        "-Wa,--noexecstack",
        "-fvisibility=hidden",
        "-fvisibility-inlines-hidden",
        "-fvisibility-global-new-delete=force-hidden",
        "-Wno-bitwise-conditional-parentheses",
        "-Wno-visibility",
        "-Wno-incompatible-pointer-types",
        "-Wno-dll-attribute-on-redeclaration",
    ],
    conlyopts = [
        "-std=c99",
        "-fexceptions",
    ],
    cxxopts = [
        "-fno-exceptions",
        "-fno-rtti",
    ],
    features = ["-default_compile_flags"],
    local_defines = [
        "_LIBUNWIND_DISABLE_VISIBILITY_ANNOTATIONS",

        # This is intentionally always defined because the macro definition means, should it only
        # build for the target specified by compiler defines. Since we pass -target the compiler
        # defines will be correct.
        "_LIBUNWIND_IS_NATIVE_ONLY",
        "_DEBUG",
        # "_LIBUNWIND_HAS_NO_THREADS", # ANY_NON_SINGLE_THREADED
        # "_DCOMPILER_RT_ARMHF_TARGET", # ARM
    ],
    hdrs = glob([
        "lib/libunwind/include/**",
        "lib/libunwind/src/*.h",
        "lib/libunwind/src/*.hpp",
    ]),
    includes = [
        "lib/libunwind/include",
        "lib/libunwind/src",
    ],
    # textual_hdrs = glob([
    #     "lib/libunwind/src/*.h"
    # ]),
    srcs = [
        "lib/libunwind/src/UnwindLevel1.c",
        "lib/libunwind/src/UnwindLevel1-gcc-ext.c",
        "lib/libunwind/src/Unwind-sjlj.c",
        "lib/libunwind/src/Unwind-wasm.c",
        "lib/libunwind/src/UnwindRegistersRestore.S",
        "lib/libunwind/src/UnwindRegistersSave.S",
        "lib/libunwind/src/gcc_personality_v0.c",

        "lib/libunwind/src/libunwind.cpp",
        "lib/libunwind/src/Unwind-EHABI.cpp",
        "lib/libunwind/src/Unwind-seh.cpp",
        "lib/libunwind/src/Unwind_AIXExtras.cpp",
    ],
    implementation_deps = [
        ":linux_system_headers",
        ":builtin_headers",
        ":c",
    ],
    visibility = ["//visibility:public"],
)
