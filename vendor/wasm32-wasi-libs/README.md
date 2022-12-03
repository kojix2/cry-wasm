# WebAssembly Libs for WASI

This repo has a set of helper scripts to build popular libraries for the WebAssembly WASI target.

Use `make <libname>` to build a library, or `make all` to make all of them. Docker is the only required dependency.

Included libraries:

| Name | Description | Source |
| --- | --- | --- |
| libc | wasi-libc based on musl 1.2.3, from wasi-sdk-16 | [Source](https://github.com/WebAssembly/wasi-libc) |
| libclang_rt | Clang's runtime library, from wasi-sdk-16 | [Source](https://github.com/WebAssembly/wasi-sdk) |
| libpcre | PCRE library version 8.45 | [Source](https://www.pcre.org/) |
