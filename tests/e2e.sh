
if [ "$GITHUB_ACTIONS" != "true" ]; then
  bazel build //tests:main --platforms=//platforms:macos_aarch64 --extra_toolchains=//toolchain:all $@
fi

# Defaults to default glibc
bazel build //tests:main --platforms=//platforms:linux_x86_64 --extra_toolchains=//toolchain:all $@
bazel build //tests:main --platforms=//platforms:linux_aarch64 --extra_toolchains=//toolchain:all $@

for i in $(seq 28 41); do
  bazel build //tests:main --platforms=//platforms/libc_aware:linux_x86_64_gnu.2.$i --extra_toolchains=//toolchain:all $@
  bazel build //tests:main --platforms=//platforms/libc_aware:linux_aarch64_gnu.2.$i --extra_toolchains=//toolchain:all $@
done

bazel build //tests:main --platforms=//platforms/libc_aware:linux_x86_64_musl --extra_toolchains=//toolchain:all $@
bazel build //tests:main --platforms=//platforms/libc_aware:linux_aarch64_musl --extra_toolchains=//toolchain:all $@
