# faiss-docker

Docker image for facebookresearch/faiss

# Pull from Docker Hub

```
docker pull nobodyxu/faiss:latest
```

For `podman` user, replace `docker` here with `podman`.

# Build

```
git clone --depth 1 https://github.com/NobodyXu/faiss-docker
docker build -t faiss:latest path_to_repo
```

 - If you want to build `faiss` with gcc toolchain, pass `--build-arg toolchain=gcc` to `docker`.
 - For `podman` user, replace `docker` here with `podman`.
