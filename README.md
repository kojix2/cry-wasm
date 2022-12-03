# CryWasm

```mermaid
flowchart LR
style id1 fill:#bbf,stroke:#f66,stroke-width:1px,color:#fff,stroke-dasharray: 5 5
style id2 fill:#bbf,stroke:#f66,stroke-width:1px,color:#fff,stroke-dasharray: 5 5
style id3 fill:#bbf,stroke:#f66,stroke-width:1px,color:#fff,stroke-dasharray: 5 5
style id4 fill:#bbf,stroke:#f66,stroke-width:1px,color:#fff,stroke-dasharray: 5 5
style id5 fill:#bbf,stroke:#f66,stroke-width:1px,color:#fff,stroke-dasharray: 5 5
    id1(Ruby) -- ripper/sorcerer --> id2(Crystal) -- compiler --> id3(LLVM_IR) -- llvm --> id4(Wasm) -- wasmer --> id5(Ruby)
```

<div align="center">
  <img src="https://user-images.githubusercontent.com/5798442/205445992-509b20d8-42c9-4341-8ea8-200d7ff3ee61.png" width=50% height=50%>
</div>

## Development

Install crystal.
Then: 

```
git clone https://github.com/kojix2/crywasm
cd crywasm
./download-wasm-libs.sh
bundle exec ruby examples/fibonacci.rb
# rake install
```

## license

MIT

This Gem contains the code of the following projects.
The former is MIT. The latter is the library needed to build Wasm in Crystal.

* [sorcerer](https://github.com/rspec-given/sorcerer)
* [wasm-libs](https://github.com/lbguilherme/wasm-libs)
