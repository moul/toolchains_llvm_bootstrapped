def platform_llvm_binary(binary):
    return select({
        "//constraint:macos_aarch64": "@static-toolchain-artifacts-darwin-arm64//:%s" % binary,
        "//constraint:linux_x86_64": "@static-toolchain-artifacts-linux-x86_64//:%s" % binary,
        "//constraint:linux_aarch64": "@static-toolchain-artifacts-linux-arm64//:%s" % binary,
    })  
