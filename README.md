# faiss-docker
Docker image for faiss

# Build

 - For image containing installed faiss only, run `docker build --squash --target Release -t faiss-llvm:Release path_to_repo`
 - For image also containing faiss build tree in `/usr/local/src/faiss`, run `docker build --squash --target WithBuildTree -t faiss-llvm:WithBuildTree path_to_repo`
 - If you want to build `faiss` with gcc toolchain, pass `--build-arg toolchain=gcc` to `docker`.


For `podman` user, replace `docker` here with `podman`.
