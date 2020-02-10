#!/bin/bash

apt-fast install -y clang lld llvm

# Configure llvm as default toolchain
## Use ld.ldd as default linker
ln -f $(which ld.lld) /usr/bin/ld

## Use clang as default compiler
update-alternatives --install /usr/bin/cc  cc  $(which clang)   100
update-alternatives --install /usr/bin/c++ c++ $(which clang++) 100
update-alternatives --install /usr/bin/cpp cpp $(which clang)   100
