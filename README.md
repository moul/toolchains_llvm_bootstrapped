# LLVM cross compilation toolchain for Bazel

> ⚠️ **Warning:** This project is still in development and is not yet ready for production.

## Description

This toolchain brings a zero config, zero sysroot, and fully hermetic C/C++ cross compilation toolchain to Bazel — out of the box.

## Basic Usage

### MODULE.bazel

Add this to your MODULE.bazel:
```python
CC_TOOLCHAIN_COMMIT = "dec0912240a57a7ff3043728def116ef022718bf"

bazel_dep(name = "cc-toolchain", version = "0.0.1")
archive_override(
    module_name = "cc-toolchain",
    urls = ["https://github.com/cerisier/cc-toolchain/archive/{}.tar.gz".format(CC_TOOLCHAIN_COMMIT)],
    integrity = "sha256-K5uiZUAAuW/+5iOiFDneXa8xffE8ehWdNipa95HfE6c=",
    strip_prefix = "cc-toolchain-{}".format(CC_TOOLCHAIN_COMMIT),
)

#TODO: Make this more user friendly :)
register_toolchains(
    "@cc-toolchain//toolchain/stage2:stage2_toolchain",
    "@cc-toolchain//toolchain:xclang_toolchain",
)
```

You can build a simple C++ program to play with the toolchain like so:
```
bazel build //tests:main --platforms=//platforms:linux_amd64
```

Or just verify that it runs on your current platform:
```sh
bazel run //tests:main
```

## Supported platforms

✅ Currently supports cross-compilation between all combinations of the following platforms:

| From ↓ / To → | macOS arm64 | macOS amd64 | Linux arm64 | Linux amd64 |
|---------------|-------------|-------------|-------------|-------------|
| **macOS arm64**  | ✅          | ✅          | ✅          | ✅          |
| **macOS amd64**  | ✅          | ✅          | ✅          | ✅          |
| **Linux arm64**  | 🚧 In Progress   | 🚧 In Progress   | ✅          | ✅          |
| **Linux amd64**  | 🚧 In Progress   | 🚧 In Progress   | ✅          | ✅          |

### musl

Compiling and linking against musl on linux is supported, but only statically.

Use `--platforms //platforms/libc_aware:linux_aarch64_musl`

> By default, the binary will be fully statically link (no dynamic linker at all).

### glibc versions

Compiling and linking against an arbitrary version of the glibC is supported.
If not specified, the default glibc version for a given target triple, as defined in Zig source code, will be used.

Use `--platforms //platforms/libc_aware:linux_x86_64_gnu.2.28`

> Note that because we use a fix set of headers (2.38), even if we are compiling against 2.17, compilation might fail for old code that includes headers that were removed in 2.28. The long term fix for this is to generate all possible headers for every single version of the glibc and use them instead of the Zig's fixed set.

### macOS notes

🚧 Cross-compiling to macOS from non-macOS hosts is nearly ready.

It will support two modes:

1.	**libSystem-only**: Compiling against a libSystem-compatible libc headers (no SDK or Apple frameworks).
2.	**macOS SDK**: Compiling against the official macOS SDK for full framework and system support.

✅ Cross-compilation from macOS to macOS is fully supported.

By default, it uses a hermetic SDK, ensuring reproducibility and isolation from the host system.

I'm planning on supporting the local SDK, opt-in.

### Other platforms

In theory, this toolchain enables cross compilation to the entire set of LLVM supported toolchains.

I have early validation of the most popular targets and os, and will progressively add support for them as time allows.

## How does it work ?

Cross compilation usually requires 2 main things:
1. **A cross compiler and cross linker:** That can generate machine code for the target platform as well as linking binaries in the target platform format.
2. **A set of target headers and prebuilt libraries:** C runtime (CRT files), libc(glibc,musl,etc..), c++ standard library (stdc++,libc++), compiler runtimes (libgcc/compiler-rt.builtins), compiler plugins (profiler/sanitizers, etc.) as well as other runtime libraries the program requires.

This toolchain only needs the former, that is a cross compiler and a cross linker, and builds all of the latter from source, eliminating the need for target specifics.

The main idea is that it uses a 1st toolchain (only the cross compiler and cross linker) to build the prerequisites of a 2nd toolchain that is used to compile end user programs.

> TODO: Detailed explanation of the process, especially for glibc stubs.

## Prior art

- https://andrewkelley.me/post/zig-cc-powerful-drop-in-replacement-gcc-clang.html I was heavily inspired by (and heavily rely on) the work of [Andrew Kelley](https://github.com/andrewrk) on the [zig](https://github.com/ziglang/zig) programming language compiler.

- https://github.com/bazel-contrib/toolchains_llvm which provides a cross compilation toolchain based on user-provided `sysroot`.

- https://github.com/uber/hermetic_cc_toolchain which prodives a Bazel cross compilation toolchain built around the `zig` binary and it's `cc` subcommand.

- https://github.com/dzbarsky/static-clang which provides stripped subset of llvm binaries for lighter dependencies, as well as a starting point for missing llvm targets build file authoring (compiler-rt, etc.).

## Roadmap

> TODO: Add remaining tasks for production readyness.

- Allow configuration with the same granularity as `toolchains_llvm` (custom llvm release, user-provided sysroot, static/dynamic linking option for the c++ standard library, libunwind etc.).
  
- Use own generated glibC headers rather than zig's.
- Use own generated linux system headers rather than zig's.
- Add basic support for asan/tsan/ubsan.
- Support `rules_foreign_cc` and `rules_go` out of the box.
- Support easy LLVM targets (arm, loongarch, mips, riscv, sparc, spirv, thumb).
- Support WASM targets.
- Support Windows.
- Support Objective C.
- Support **cross** compilation to macOS (Requires unpacking the SDK on linux).
- Tests and hardening.

### Known issues

- For now, the libc++ is always compiled and linker (even tho compiled -as-needed).

# Thanks

None of this would have been possible without the support of [zml.ai](https://zml.ai/) for whom this toolchain has initially been created. They are building an **high performance inference suite** and this is by far the most impressive bazel project I've worked on.

A particular thank you to [@steeve](https://github.com/steeve), the founder of [zml.ai](https://zml.ai) for planting the idea and providing guidance and support.

Special thanks to the Bazel community for answering many of my interrogations on the Bazel slack and providing guidance when needed.

Special mention for [@dzbarsky](https://github.com/dzbarsky), [@fmeum](https://github.com/fmeum), [@keith](https://github.com/keith), [@armandomontanez](https://github.com/armandomontanez) and the whole [bazelbuild/rules_cc](https://github.com/bazelbuild/rules_cc) team at Google for being supportive and reactive!
