# cry-wasm

[![test](https://github.com/kojix2/cry-wasm/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/cry-wasm/actions/workflows/ci.yml)

cry-wasm speeds up [Ruby](https://github.com/ruby/ruby) code.

By applying simple type restrictions to Ruby code, convert it to [Crystal](https://github.com/crystal-lang/crystal) code, compile it to [WebAssembly](https://webassembly.org/), and call it with [Wasmer](https://github.com/wasmerio/wasmer).

```mermaid
flowchart LR
style id1 fill:#c5c,stroke:#f66,stroke-width:1px,color:#fff
style id2 fill:#555,stroke:#3ff,stroke-width:1px,color:#fff
style id3 fill:#66f,stroke:#f66,stroke-width:1px,color:#fff
style id4 fill:#c5c,stroke:#ff1,stroke-width:1px,color:#fff
    id1(Ruby Code) -- ripper/sorcerer --> id2(Crystal Code) -- crystal compiler --> id3[WebAssembly]
    id4(Ruby Code) <-- wasmer --> id3[WebAssembly]
```

:space_invader: _highly experimental_

## Quick Start

```ruby
require 'cry/wasm'

class Fibonacci
  extend Cry::Wasm            # <-- Extend Cry::Wasm module

  def initialize; end

  cry [:Int32], :Int32        # <-- Set crystal [argument], return types
  def fib(n)
    if n <= 1
      1
    else
      fib(n - 1) + fib(n - 2)
    end
  end

  cry_wasm                    # <-- Crystal compiles the fib method into Wasm.
end

Fibonacci.new.fib(40)         # <-- The wasm function is called here!
```

## Benchmark

[fib_bench.rb](https://github.com/kojix2/cry-wasm/blob/main/examples/fib_bench.rb) - 10 x faster on the [Fibonacci benchmark](https://crystal-lang.org/2016/07/15/fibonacci-benchmark/).

```
                 user     system      total        real
fib_ruby(40)  7.461878   0.004760   7.466638 (  7.466798)
fib_wasm(40)  0.628013   0.000025   0.628038 (  0.628096)
```

<img src="https://user-images.githubusercontent.com/5798442/205485566-5f7d1bae-4908-43a1-8f9a-801ae8d7d33e.png" width=20% height="20%">

## How does this work?

1. Extend the Cry::Wasm module to the target class.
1. Write the type information just before the method.
   1. Use the `cry` method to restrict argument types and return types.
1. Once the method is defined, Cry::Wasm captures the source code.
   1. [Ripper](https://ruby-doc.org/stdlib-3.1.2/libdoc/ripper/rdoc/Ripper.html) converts source code to [S-expression](https://en.wikipedia.org/wiki/S-expression).
   1. Extracts the S-expression of the target method from the S-expression.
   1. [Sorcerer](https://github.com/rspec-given/sorcerer) recovers the Ruby source code of the target method from the S-expression.
   1. Add Crystal type restrictions to the Ruby source code to generate a Crystal code block.
   1. Cry::Wasm stores the Crystal code block.
1. The Crystal compiler and wasm-ld compile the Crystal code into WebAssembly.
   1. Call the `cry_wasm` method to build the crystal code blocks.
1. The compiled byte_code is read, and an instance of Wasmer is created.
1. The target methods are dynamically redefined to call Wasmer functions.

<img src="doc/overview.drawio.svg" width=20% height=20%>

## Limitations

- Cry::Wasm allows you to define functions, not Crystal methods
  - default arguments, keyword arguments, and block arguments are not available.
- Currently, only numbers are accepted as arguments. In the future, strings may also be acceptable.

## Installation

1. Install [Crystal](https://github.com/crystal-lang/crystal). Installation instructions for each platform are [here](https://crystal-lang.org/install/).
1. Install [Rust](https://www.rust-lang.org/). Rust is required to compile the [wasmer gem](https://github.com/wasmerio/wasmer-ruby). 
1. Install llvm for macOS and lld for Ubuntu. Set PATH so that `wasm-ld` can be called.
    1. For example, if you install llvm on macOS with homebrew, `PATH="/usr/local/opt/llvm/bin:$PATH"` or `PATH="/opt/homebrew/Cellar/llvm/<version>/bin:$PATH"`
1. Download [WebAssembly Libs for WASI](https://github.com/lbguilherme/wasm-libs) with `./download-wasm-libs.sh`

```sh
# Not yet available. Please see development section.
gem install cry/wasm
```

Tested on macOS and Ubuntu using [Github Actions](https://github.com/kojix2/cry-wasm/blob/main/.github/workflows/ci.yml).

## Development

- [Trying out WASM Support](https://forum.crystal-lang.org/t/trying-out-wasm-support/4508) - A thread in the Crystal Forum on how to compile a wasm from crystal.
- [wasm-libs](https://github.com/lbguilherme/wasm-libs) - WebAssembly Libs for WASI. You need to download the compiled wasm library.

```
git clone https://github.com/kojix2/cry-wasm
cd cry-wasm
bundle install
bundle exec rake vendor:wasi_libs
bundle exec ruby examples/fibonacci.rb
# rake install
```

- [Crystal で WebAssembly に出力した関数を Ruby から呼び出す](https://qiita.com/kojix2/items/b233f1419b26f7fc0e1b)

## license

MIT
