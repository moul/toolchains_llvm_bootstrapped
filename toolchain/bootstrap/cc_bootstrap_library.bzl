load("@with_cfg.bzl", "with_cfg")
load("@rules_cc//cc:cc_library.bzl", "cc_library")

cc_bootstrap_library, _cc_bootstrap_library_internal = with_cfg(
    cc_library,
).set(
    "host_platform",
    Label("//toolchain/bootstrap:bootstrap_stage_1_platform"),
).build()
