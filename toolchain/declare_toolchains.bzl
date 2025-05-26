
load("//platforms:common.bzl", _arch_aliases = "ARCH_ALIASES", _supported_targets = "SUPPORTED_TARGETS")

#TODO(cerisier): Support extra exec_compatible_with constraints
def declare_toolchains():
    for (target_os, target_cpu) in _supported_targets:
        native.toolchain(
            name = "{}_{}".format(target_os, target_cpu),
            target_compatible_with = [
                "@platforms//cpu:{}".format(target_cpu),
                "@platforms//os:{}".format(target_os),
            ],
            toolchain = Label("//toolchain:cc_toolchain"),
            toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
            # exec_compatible_with = ["@platforms//os:{exec_os}", "@platforms//cpu:{exec_arch}"],
            visibility = ["//visibility:public"],
        )

        for alias in _arch_aliases.get(target_cpu, []):
            native.toolchain(
                name = "{}_{}".format(target_os, alias),
                target_compatible_with = [
                    "@platforms//cpu:{}".format(target_cpu),
                    "@platforms//os:{}".format(target_os),
                ],
                toolchain = Label("//toolchain:cc_toolchain"),
                toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
                # exec_compatible_with = ["@platforms//os:{exec_os}", "@platforms//cpu:{exec_arch}"],
                visibility = ["//visibility:public"],
            )
