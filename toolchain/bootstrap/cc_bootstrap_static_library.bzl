load("@with_cfg.bzl", "with_cfg")

cc_bootstrap_static_library, _cc_bootstrap_static_library_internal = with_cfg(
    native.cc_static_library,
).set(
    "host_platform",
    Label("//toolchain/bootstrap:bootstrap_stage_1_platform"),
).build()
