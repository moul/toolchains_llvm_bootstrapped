
if [ "$GITHUB_ACTIONS" != "true" ]; then
  bazel build //tests:main --platforms=//platforms:macos_aarch64 --extra_toolchains=//toolchain:all $@
fi

# Defaults to default glibc
bazel build //tests:main --platforms=//platforms:linux_x86_64 --extra_toolchains=//toolchain:all $@
bazel build //tests:main --platforms=//platforms:linux_aarch64 --extra_toolchains=//toolchain:all $@

start=28
if [ "$GITHUB_ACTIONS" == "true" ]; then
  start=41
fi
for i in $(seq $start 41); do
  bazel build //tests:main --platforms=//platforms/libc_aware:linux_x86_64_gnu.2.$i --extra_toolchains=//toolchain:all $@
  bazel build //tests:main --platforms=//platforms/libc_aware:linux_aarch64_gnu.2.$i --extra_toolchains=//toolchain:all $@
done

bazel build //tests:main --platforms=//platforms/libc_aware:linux_x86_64_musl --extra_toolchains=//toolchain:all $@
bazel build //tests:main --platforms=//platforms/libc_aware:linux_aarch64_musl --extra_toolchains=//toolchain:all $@
