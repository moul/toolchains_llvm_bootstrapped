load("@cc-toolchain//libc/glibc/extension:make_select_glibc_repository_target.bzl", "make_select_glibc_repository_target")

package(default_visibility = ["//visibility:public"])

alias(
    name = "gnu_libc_headers",
    actual = make_select_glibc_repository_target("@glibc_headers", "gnu_libc_headers"),
)

alias(
    name = "glibc_headers_directory",
    actual = make_select_glibc_repository_target("@glibc_headers", "glibc_headers_directory"),
)

alias(
    name = "c_nonshared",
    actual = make_select_glibc_repository_target("@glibc", "c_nonshared"),
)

alias(
    name = "glibc_Scrt1.static",
    actual = make_select_glibc_repository_target("@glibc", "glibc_Scrt1.static"),
)

