load("//constraints/libc:libc_versions.bzl", "LIBCS")
load("//platforms:common.bzl", "LIBC_SUPPORTED_TARGETS")
load(":libc_kernel_versions.bzl", "LIBC_KERNEL_VERSIONS")
load(":kernel_helpers.bzl", "arch_to_kernel_arch")

def make_select_kernel_headers_repository_target(bazel_target):
    """Select the right kernel headers repository based on the target architecture and the libc version."""
    selection = {}
    for (target_os, target_arch) in LIBC_SUPPORTED_TARGETS:
        # TODO(cerisier): Use the right default glibc version for the target architecture.
        #
        # We should choose the minimum version of the glibc that supports the
        # target architecture. For now 2.28 is ok because we only support x86_64
        # and aarch64. But loongarch, risc and csky for instance were 
        # introduced later.
        kernel_version = LIBC_KERNEL_VERSIONS["gnu.2.28"]
        apparent_target = "@linux_kernel_headers_{}.{}//:{}".format(arch_to_kernel_arch(target_arch), kernel_version, bazel_target)
        selection["@toolchains_llvm_bootstrapped//platforms/config/libc_aware:{}_{}".format(target_os, target_arch)] = apparent_target

        for libc_version in LIBCS:
            kernel_version = LIBC_KERNEL_VERSIONS[libc_version]
            apparent_target = "@linux_kernel_headers_{}.{}//:{}".format(arch_to_kernel_arch(target_arch), kernel_version, bazel_target)
            selection["@toolchains_llvm_bootstrapped//platforms/config/libc_aware:{}_{}_{}".format(target_os, target_arch, libc_version)] = apparent_target

    return select(selection)
