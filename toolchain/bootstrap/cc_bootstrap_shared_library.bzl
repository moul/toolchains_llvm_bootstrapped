load("@with_cfg.bzl", "with_cfg")

cc_bootstrap_shared_library, _cc_bootstrap_shared_library_internal = with_cfg(
    native.cc_shared_library,
    extra_providers = [CcSharedLibraryInfo],
).set(
    "host_platform",
    Label("//toolchain/bootstrap:bootstrap_stage_1_platform"),
).build()
