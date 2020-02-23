#!/bin/bash

apt-auto install -y --no-install-recommends clang lld llvm libomp-dev

# Configure llvm as default toolchain
## Use ld.ldd as default linker
ln -f $(which ld.lld) /usr/bin/ld

## Use clang as default compiler
update-alternatives --install /usr/bin/cc  cc  $(which clang)   100
update-alternatives --install /usr/bin/c++ c++ $(which clang++) 100
update-alternatives --install /usr/bin/cpp cpp $(which clang)   100
