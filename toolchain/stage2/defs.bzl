STAGE2_COPT = select({
    Label("//config:stage2_optimization_mode_debug"): [
        "-D_DEBUG",
        "-O0",
        "-g",
    ],
    "//conditions:default": [
        "-DNDEBUG",
        "-O2",
    ],
})
