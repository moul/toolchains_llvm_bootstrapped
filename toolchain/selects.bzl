def platform_llvm_binary(binary):
    return select({
        "//platforms/config:macos_aarch64": "@static-toolchain-artifacts-darwin-arm64//:%s" % binary,
        "//platforms/config:linux_x86_64": "@static-toolchain-artifacts-linux-x86_64//:%s" % binary,
        "//platforms/config:linux_aarch64": "@static-toolchain-artifacts-linux-arm64//:%s" % binary,
    })

def platform_llvm_binaries(binaries):
    return select({
        "//platforms/config:macos_aarch64": ["@static-toolchain-artifacts-darwin-arm64//:%s" % binary for binary in binaries],
        "//platforms/config:linux_x86_64": ["@static-toolchain-artifacts-linux-x86_64//:%s" % binary for binary in binaries],
        "//platforms/config:linux_aarch64": ["@static-toolchain-artifacts-linux-arm64//:%s" % binary for binary in binaries],
    })
