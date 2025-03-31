
load("@aspect_bazel_lib//lib:tar.bzl", "tar")

def release_tar(name):

    BINS = [
        "@llvm-project//clang:clang.stripped",
        "@llvm-project//lld:lld.stripped",
        "@llvm-project//llvm:llvm-ar.stripped",
        "@llvm-project//llvm:llvm-as.stripped",
        "@llvm-project//llvm:llvm-libtool-darwin.stripped",
        "@llvm-project//llvm:llvm-nm.stripped",
        "@llvm-project//llvm:llvm-objcopy.stripped",
    ] + [
        "@glibc-stubs-generator//:glibc-stubs-generator"
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
bin/clang uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//clang:clang.stripped)
bin/clang++ uid=0 gid=0 time=1672560000 mode=0755 type=link link=clang
bin/clang-cpp uid=0 gid=0 time=1672560000 mode=0755 type=link link=clang
bin/lld uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//lld:lld.stripped)
bin/ld64.lld uid=0 gid=0 time=1672560000 mode=0755 type=link link=ld.lld
bin/wasm-ld uid=0 gid=0 time=1672560000 mode=0755 type=link link=ld.lld
bin/llvm-ar uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//llvm:llvm-ar.stripped)
bin/llvm-as uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//llvm:llvm-as.stripped)
bin/llvm-libtool-darwin uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//llvm:llvm-libtool-darwin.stripped)
bin/llvm-nm uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//llvm:llvm-nm.stripped)
bin/llvm-objcopy uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @llvm-project//llvm:llvm-objcopy.stripped)
bin/glibc-stubs-generator uid=0 gid=0 time=1672560000 mode=0755 type=file content=$(location @glibc-stubs-generator//:glibc-stubs-generator)
bin/llvm-strip uid=0 gid=0 time=1672560000 mode=0755 type=link link=llvm-objcopy
bin/clang-tidy uid=0 gid=0 time=1672560000 mode=0755 type=link link=empty
bin/clang-format uid=0 gid=0 time=1672560000 mode=0755 type=link link=empty
bin/clangd uid=0 gid=0 time=1672560000 mode=0755 type=link link=empty
bin/llvm-symbolizer uid=0 gid=0 time=1672560000 mode=0755 type=link link=empty
bin/glibc-stubs-generator
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
