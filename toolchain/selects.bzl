def platform_llvm_binary(binary):
    return select({
        "//platforms/config:macos_aarch64": "@llvm-toolchain-minimal-20.1.1-darwin-arm64//:%s" % binary,
        "//platforms/config:linux_x86_64": "@llvm-toolchain-minimal-20.1.1-linux-amd64//:%s" % binary,
        "//platforms/config:linux_aarch64": "@llvm-toolchain-minimal-20.1.1-linux-arm64//:%s" % binary,
    })

def platform_extra_binary(binary):
    return select({
        "//platforms/config:macos_aarch64": "@static-extras-toolchain-artifacts-darwin-arm64//:%s" % binary,
        "//platforms/config:linux_x86_64": "@static-extras-toolchain-artifacts-linux-amd64//:%s" % binary,
        "//platforms/config:linux_aarch64": "@static-extras-toolchain-artifacts-linux-arm64//:%s" % binary,
    })

def platform_llvm_binaries(binaries):
    return select({
        "//platforms/config:macos_aarch64": ["@llvm-toolchain-minimal-20.1.1-darwin-arm64//:%s" % binary for binary in binaries],
        "//platforms/config:linux_x86_64": ["@llvm-toolchain-minimal-20.1.1-linux-amd64//:%s" % binary for binary in binaries],
        "//platforms/config:linux_aarch64": ["@llvm-toolchain-minimal-20.1.1-linux-arm64//:%s" % binary for binary in binaries],
    })
