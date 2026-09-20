#!/bin/sh

set -eux

cd `dirname $0`
rm -rf source/wasm_drt/*
mkdir source/wasm_drt/wasip2

# Prepare `imports` world
wit-bindgen d \
    --out-dir source/wasm_drt \
    --root-package=wasm_drt.wasip2 \
    -w imports \
    wit
mv source/wasm_drt/wit/wasi/* source/wasm_drt/wasip2
mv source/wasm_drt/wit/common.d source/wasm_drt/wasip2/wit.d
rm -rf source/wasm_drt/wit/

# Prepare `exports` world.
# This world is not standard, but we want flexibility here
# to have JUST imports when desirable, while not needing a separate
# package for the world with imports + exports
wit-bindgen d \
    --out-dir source/wasm_drt \
    --root-package=wasm_drt.wasip2 \
    -w exports \
    wit
mv source/wasm_drt/wit/wasi/cli/* source/wasm_drt/wasip2
rm -rf source/wasm_drt/wit/


find source/wasm_drt/wasip2 \
    -type f \
    -exec sed -i 's/wasm_drt\.wasip2\.common/wasm_drt\.wasip2\.wit/g; s/wasm_drt\.wasip2\.wasi/wasm_drt\.wasip2/g;' {} \+

# Remangle the run wrapper as `_start` to appease wasm-ld
sed -i 's/pragma(mangle, "__wit_export_wasi:cli__run@0\.2\.12::run")/pragma(mangle, "_start")/g;' source/wasm_drt/wasip2/run/exports.d
