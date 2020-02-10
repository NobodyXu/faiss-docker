# faiss-docker
Docker image for faiss

# Build

`docker build --squash -t faiss path_to_repo` to build faiss with llvm toolchain.

To build with gcc toolchain, pass `--build-arg toolchain=gcc` to `docker`.

## *NOTE*:

For `podman` user, replace `docker` here with `podman`.
