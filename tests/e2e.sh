bazel build //tests:main --platforms=//platforms:macos_aarch64

# Defaults to default glibc
bazel build //tests:main --platforms=//platforms:linux_x86_64
bazel build //tests:main --platforms=//platforms:linux_aarch64

for i in $(seq 28 41); do
  bazel build //tests:main --platforms=//platforms/libc_aware:linux_x86_64_gnu.2.$i
  bazel build //tests:main --platforms=//platforms/libc_aware:linux_aarch64_gnu.2.$i
done

bazel build //tests:main --platforms=//platforms/libc_aware:linux_x86_64_musl
bazel build //tests:main --platforms=//platforms/libc_aware:linux_aarch64_musl
