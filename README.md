# faiss-docker

Docker image for facebookresearch/faiss

# Pull from Docker Hub

```
docker pull nobodyxu/faiss:latest
```

For `podman` user, replace `docker` here with `podman`.

# Build

 - Run `docker build -t faiss-llvm:latest path_to_repo` to build the image.
 - If you want to build `faiss` with gcc toolchain, pass `--build-arg toolchain=gcc` to `docker`.
 - For `podman` user, replace `docker` here with `podman`.
