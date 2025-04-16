
load("@aspect_bazel_lib//lib:tar.bzl", "tar")

# .stripped is currently not buildable on macosx when cross compiling clang with hermetic_cc_toolchain because it doesn't expose the strip binary
BUILD_STRIPPED = False

def llvm_release(name):
    BINS = [
        "@llvm-project//clang:clang{}".format(".stripped" if BUILD_STRIPPED else ""),
        "@llvm-project//lld:lld{}".format(".stripped" if BUILD_STRIPPED else ""),
        "@llvm-project//llvm:llvm-ar{}".format(".stripped" if BUILD_STRIPPED else ""),
        "@llvm-project//llvm:llvm-as{}".format(".stripped" if BUILD_STRIPPED else ""),
        "@llvm-project//llvm:llvm-libtool-darwin{}".format(".stripped" if BUILD_STRIPPED else ""),
        "@llvm-project//llvm:llvm-nm{}".format(".stripped" if BUILD_STRIPPED else ""),
        "@llvm-project//llvm:llvm-objcopy{}".format(".stripped" if BUILD_STRIPPED else ""),
    ] + [
        # "@llvm-project//llvm-cov:llvm-cov",
        # "@llvm-project//llvm-dwp:llvm-dwp",
        # "@llvm-project//llvm-objdump:llvm-objdump",
        # "@llvm-project//llvm-profdata:llvm-profdata",
    ]

    native.genrule(
        name = "{}_mtree".format(name),
        srcs = BINS,
        cmd = """\
cat <<EOF > $(@)
bin/clang uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//clang:clang{strip_suffix})
bin/clang++ uid=0 gid=0 time=1672560000 mode=0755 type=link link=clang
bin/clang-cpp uid=0 gid=0 time=1672560000 mode=0755 type=link link=clang
bin/lld uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//lld:lld{strip_suffix})
bin/ld64.lld uid=0 gid=0 time=1672560000 mode=0755 type=link link=ld.lld
bin/wasm-ld uid=0 gid=0 time=1672560000 mode=0755 type=link link=ld.lld
bin/llvm-ar uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//llvm:llvm-ar{strip_suffix})
bin/llvm-as uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//llvm:llvm-as{strip_suffix})
bin/llvm-libtool-darwin uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//llvm:llvm-libtool-darwin{strip_suffix})
bin/llvm-nm uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//llvm:llvm-nm{strip_suffix})
bin/llvm-objcopy uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//llvm:llvm-objcopy{strip_suffix})
bin/llvm-strip uid=0 gid=0 time=1672560000 mode=0755 type=link link=llvm-objcopy
bin/clang-tidy uid=0 gid=0 time=1672560000 mode=0755 type=link link=empty
bin/clang-format uid=0 gid=0 time=1672560000 mode=0755 type=link link=empty
bin/clangd uid=0 gid=0 time=1672560000 mode=0755 type=link link=empty
bin/llvm-symbolizer uid=0 gid=0 time=1672560000 mode=0755 type=link link=empty
EOF
""".format(
            strip_suffix = ".stripped" if BUILD_STRIPPED else "",
        ),
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
