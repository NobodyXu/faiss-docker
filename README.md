# faiss-docker

Docker image for facebookresearch/faiss

# Build

 - Run `docker build --target latest -t faiss-llvm:latest path_to_repo` to build the image.
 - If you want to build `faiss` with gcc toolchain, pass `--build-arg toolchain=gcc` to `docker`.
 - For `podman` user, replace `docker` here with `podman`.
