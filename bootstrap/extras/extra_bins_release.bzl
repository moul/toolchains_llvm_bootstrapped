load("@aspect_bazel_lib//lib:tar.bzl", "tar")

def extra_bins_release(name):
    BINS = [
        "@glibc-stubs-generator//:glibc-stubs-generator"
    ]

    native.genrule(
        name = "{}_mtree".format(name),
        srcs = BINS,
        cmd = """\
cat <<EOF > $(@)
bin/glibc-stubs-generator uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @glibc-stubs-generator//:glibc-stubs-generator)
EOF
""",
        outs = [
            "{}.mtree".format(name),
        ],
    )

    tar(
        name = name,
        srcs = BINS,
        args = [
            "--options",
            "zstd:compression-level=22",
        ],
        compress = "zstd",
        mtree = "{}_mtree".format(name),
    )
