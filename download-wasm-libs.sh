wget https://github.com/lbguilherme/wasm-libs/releases/download/0.0.2/wasm32-wasi-libs.tar.gz
mkdir -p vendor/wasm32-wasi-libs
tar -xvf wasm32-wasi-libs.tar.gz -C vendor/wasm32-wasi-libs
rm wasm32-wasi-libs.tar.gz