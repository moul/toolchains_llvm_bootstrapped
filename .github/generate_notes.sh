#!/bin/bash

set -euo pipefail

readonly new_version=$1

cat <<EOF
## What's Changed

TODO

## MODULE.bazel

\`\`\`bzl
bazel_dep(name = "toolchains_llvm_bootstrapped", version = "$new_version")

register_toolchains(
    "@toolchains_llvm_bootstrapped//toolchain/...",
)
\`\`\`
EOF
