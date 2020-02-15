# faiss-docker

![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/nobodyxu/faiss)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/nobodyxu/faiss)

![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/nobodyxu/faiss/latest)

Docker image for facebookresearch/faiss

## Pull from Docker Hub

```
# For latest build
docker pull nobodyxu/faiss:latest
# For latest build with src
docker pull nobodyxu/faiss:latest-with-src
```

For `podman` user, replace `docker` here with `podman`.

## Build

```
git clone --depth 1 https://github.com/NobodyXu/faiss-docker

# For latest build
docker build --target Installed -t faiss:latest path/to/repo
# For latest build with src
docker build --target with-src -t faiss:latest-with-src path/to/repo
```

 - If you want to build `faiss` with gcc toolchain, pass `--build-arg toolchain=gcc` to `docker`.
 - For `podman` user, replace `docker` here with `podman`.
