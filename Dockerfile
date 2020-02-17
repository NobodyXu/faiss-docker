FROM nobodyxu/intel-mkl:latest-debian-buster AS intel-mkl

FROM intel-mkl AS Env_setup

ARG toolchain=llvm
ADD install_llvm.sh /tmp/

# Disable interctive debconf post-install-configuration
ENV DEBIAN_FRONTEND=noninteractive

# Install apt-fast to speed up downloading packages
ADD apt-fast/* /tmp/apt-fast/
RUN /tmp/apt-fast/install_apt-fast.sh

# Install softwares for downloading
RUN apt-fast update && apt-fast install -y git ca-certificates curl wget

# Install necessary build tools and headers/libs
RUN apt-fast update && \
    apt-fast install -y --no-install-recommends \
                        gcc build-essential make swig swig3.0 python3-dev python-dev python3-numpy python-numpy \
                        python3-setuptools python-setuptools python3-pip python-pip python3-scipy python-scipy \
                        ffmpeg libffmpeg*-dev

# Install llvm only when asked
RUN if [ $toolchain = "llvm" ]; then /tmp/install_llvm.sh; fi

# Remove apt-fast and purge basic software for adding apt repository
RUN /tmp/apt-fast/remove_apt-fast.sh
RUN apt-get remove -y apt-transport-https gnupg2 gnupg-agent software-properties-common apt-utils
RUN apt-get autoremove -y
# Clean /tmp, cache of downloaded packages and apt indexes
RUN apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/*

# Workaround for 'Python.h not found'
RUN bash -c 'for py_include in /usr/include/python*; do ln -s $py_include /usr/local/include; done'

# Add user as building software as root is just **not a good idea**
RUN useradd -m user
RUN mkdir -p /usr/local/src && chmod -R 777 /usr/local/src

FROM intel-mkl AS base
COPY --from=Env_setup / /

# Workaround for 'Cannot lod libmkl_acx2.so or libmkl_def.so', learnt from:
#     https://software.intel.com/en-us/forums/intel-math-kernel-library/topic/748309
ENV LD_PRELOAD=/opt/intel/mkl/lib/intel64/libmkl_def.so:/opt/intel/mkl/lib/intel64/libmkl_avx2.so:/opt/intel/mkl/lib/intel64/libmkl_core.so:/opt/intel/mkl/lib/intel64/libmkl_intel_lp64.so:/opt/intel/mkl/lib/intel64/libmkl_intel_thread.so:/opt/intel/lib/intel64_lin/libiomp5.so
# Set flags
ENV CC=/usr/bin/cc CXX=/usr/bin/c++ CFLAGS="-flto" CXXFLAGS="-flto"

# ... Now build the software!
FROM base AS Build

## Install su-exec to replace sudo
ADD https://github.com/NobodyXu/su-exec/releases/download/v0.3/su-exec /usr/local/bin/su-exec
RUN chmod a+xs /usr/local/bin/su-exec

USER user
ARG branch=master
RUN git clone --depth 1 -b $branch https://github.com/facebookresearch/faiss /usr/local/src/faiss
WORKDIR /usr/local/src/faiss

RUN LDFLAGS=-L/opt/intel/mkl/lib/intel64/ ./configure --without-cuda

RUN make -j $(nproc)
RUN make -C python -j $(nproc)

RUN make test

RUN su-exec root:root make install
RUN su-exec root:root make -C python install

# Move faiss to another directory for coping and chowning in latest
WORKDIR /
RUN su-exec root:root mv /usr/local/src/faiss /home/user/faiss

## Remove su-exec
RUN su-exec root:root rm /usr/local/bin/su-exec

RUN rm -rf /tmp/*

FROM base AS release
COPY --from=Build /usr/local/ /usr/local/
USER user

FROM release AS with-src
COPY --from=Build --chown=user:user /home/user/faiss /usr/local/src/faiss/
WORKDIR /usr/local/src/faiss
