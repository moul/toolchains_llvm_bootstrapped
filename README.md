# LLVM cross compilation toolchain for Bazel

> ⚠️ **Warning:** This project is still in development and may break.

## Description

This toolchain brings a zero sysroot, fully hermetic C/C++ cross compilation toolchain to Bazel based on LLVM.

It can cross compile out of the box without any kind of extra configuration.

It is based on the new `rules_cc` rule base toolchain API and will work out of the box
for the entire `rules_cc` ruleset.

## Installation

See instructions in the [releases](https://github.com/cerisier/toolchains_cc/releases) for installation.

## Examples

If you clone this repository, you can test this toolchain for all the registered platforms:

See all supported platforms:
```
bazel query 'kind(platform, //platforms/...)'
```

Build a simple C++ program to play with the toolchain:
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

To target musl, use:
`--platforms //platforms/libc_aware:linux_aarch64_musl`

> By default, the binary will be fully statically link (no dynamic linker at all).

### GNU C Library ("glibc") versions

Compiling and linking against an arbitrary version of the glibc is supported.
By default, the earliest glibc version that supports your target is used (2.28 in most case).

To target a specific version, use:
`--platforms //platforms/libc_aware:linux_x86_64_gnu.2.28`

Behind the scenes, your code is compiled using the appropriate headers for the
target version, and linked against a stub glibc that includes only the symbols
available in that version.

This guarantees that your program will run on any system with that exact glibc
version or newer, since it never relies on symbols introduced in later versions.

### macOS notes

🚧 Cross-compiling to macOS from non-macOS hosts is nearly ready.

It will support two modes:

1.	**libSystem-only**: Compiling against a libSystem-compatible libc headers (no SDK or Apple frameworks).
2.	**macOS SDK**: Compiling against the official macOS SDK for full framework and system support.

✅ Compilation from macOS to macOS is supported.

By default, it uses a hermetic SDK, ensuring reproducibility and isolation from the host system.
The SDK is the official macOS SDK and is downloaded from apple CDN directly.

I'm planning on supporting the local SDK, opt-in.

### Other platforms

In theory, this toolchain enables cross compilation to the entire set of LLVM supported toolchains.

I have early validation of the most popular targets and os, and will progressively add support for them as time allows.

## How does it work ?

Cross compilation usually requires 2 main things:
1. **A cross-compiler and cross-linker** capable of generating and linking binaries for the target platform.
2. **Target-specific headers and libraries** such as the C runtime (CRT files), libc (glibc, musl, etc.), C++ standard library (libstdc++, libc++), compiler runtimes (libgcc, compiler-rt), and optional components like profilers or sanitizers.

This toolchain only needs the former, that is, a cross compiler and a cross linker, and builds all of the latter from source, eliminating the need for target specifics.

This toolchain simplifies the process by requiring only the cross-compiler and cross-linker.
It builds all the target-specific components from source.

To build programs, this toolchains is composed of 2 bazel toolchains:
1. A raw toolchain used to compile the target-specific components.
2. A final toolchain used to compile user programs, including the components built by the 1st.

> TODO: Detailed explanation of the process, especially for glibc stubs.

## Prior art

- https://andrewkelley.me/post/zig-cc-powerful-drop-in-replacement-gcc-clang.html I was heavily inspired by (and heavily rely on) the work of [Andrew Kelley](https://github.com/andrewrk) on the [zig](https://github.com/ziglang/zig) programming language compiler.

- https://github.com/bazel-contrib/toolchains_llvm which provides a cross compilation toolchain based on user-provided `sysroot`.

- https://github.com/uber/hermetic_cc_toolchain which prodives a Bazel cross compilation toolchain built around the `zig` binary and it's `cc` subcommand.

- https://github.com/dzbarsky/static-clang which provides stripped subset of llvm binaries for lighter dependencies, as well as a starting point for missing llvm targets build file authoring (compiler-rt, etc.).

## Roadmap

> TODO: Add remaining tasks for production readyness.

- Allow configuration with the same granularity as `toolchains_llvm` (custom llvm release, user-provided sysroot, static/dynamic linking option for the c++ standard library, libunwind etc.).
- [IN PROGRESS] Support linking against libstd++ (`libstdcxx` branch).
- Support for asan/tsan/ubsan.
- Support `rules_foreign_cc` and `rules_go` out of the box.
- Support easy LLVM targets (arm, loongarch, mips, riscv, sparc, spirv, thumb).
- Support WASM targets.
- Support Windows.
- Support Objective C.
- Support **cross-compilation** to macOS (Requires unpacking the SDK on linux).
- Tests and hardening.

### Known issues

- The C Library is always compiled and linked.
- The C++ standard library is always compiled and linked (with -as-needed).
- The final toolchain makes `-nostdinc`, `-nostdlib` family of flags unapplicable.
  (One idea would be to expose different toolchains for this usecase, or `config_settings`)

# Thanks

None of this would have been possible without the support of [zml.ai](https://zml.ai/) for whom this toolchain has initially been created. They are building an **high performance inference suite** and this is by far the most impressive bazel project I've worked on.

A particular thank you to [@steeve](https://github.com/steeve), the founder of [zml.ai](https://zml.ai) for planting the idea and providing guidance and support.

Special thanks to the Bazel community for answering many of my interrogations on the Bazel slack and providing guidance when needed.

Special mention for [@dzbarsky](https://github.com/dzbarsky), [@fmeum](https://github.com/fmeum), [@keith](https://github.com/keith), [@armandomontanez](https://github.com/armandomontanez) and the whole [bazelbuild/rules_cc](https://github.com/bazelbuild/rules_cc) team at Google for being supportive and reactive!
