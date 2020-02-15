# Prepare to build faiss
FROM debian:buster AS Preparation

ARG toolchain=llvm
ADD install_llvm.sh /tmp/

ENV DEBIAN_FRONTEND=noninteractive

# Install apt-fast to speed up downloading packages
ADD apt-fast/* /tmp/apt-fast/
RUN /tmp/apt-fast/install_apt-fast.sh

# Install basic software for adding apt repository and downloading source code to compile
RUN apt-fast update && \
    apt-fast install -y --no-install-recommends apt-transport-https ca-certificates gnupg2 gnupg-agent \
                                                software-properties-common wget curl git apt-utils

# Install MKL
## Install official Intel MKL repository for apt
## Commands below adapted from:
##     https://software.intel.com/en-us/articles/installing-intel-free-libs-and-python-apt-repo
##     https://github.com/eddelbuettel/mkl4deb
RUN curl https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB | apt-key add -
RUN wget --progress=dot https://apt.repos.intel.com/setup/intelproducts.list -O /etc/apt/sources.list.d/intelproducts.list
RUN apt-fast update && apt-fast install -y $(apt-cache search intel-mkl-2020 | cut -d '-' -f 1,2,3,4  | tail -n 1)

## Configure dynamic linker to use MKL
RUN echo "/opt/intel/lib/intel64"     >  /etc/ld.so.conf.d/mkl.conf
RUN echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/mkl.conf
RUN ldconfig

RUN echo "MKL_THREADING_LAYER=GNU" >> /etc/environment

# Install necessary build tools and headers/libs
RUN apt-fast update && \
    apt-fast install -y --no-install-recommends \
                        gcc build-essential make swig swig3.0 python3-dev python-dev python3-numpy python-numpy \
                        python3-setuptools python-setuptools python3-pip python-pip python3-scipy python-scipy \
                        ffmpeg libffmpeg*-dev

RUN if [ $toolchain = "llvm" ]; then /tmp/install_llvm.sh; fi

# Remove apt-fast and purge basic software for adding apt repository
RUN /tmp/apt-fast/remove_apt-fast.sh
RUN apt-get remove -y apt-transport-https gnupg2 gnupg-agent software-properties-common apt-utils
RUN apt-get autoremove -y

# Clean /tmp, cache of downloaded packages and apt indexes
RUN rm -rf /tmp/* && apt-get clean && rm -rf /var/lib/apt/lists/*

FROM Preparation AS Configuration

# Workaround for 'Python.h not found'
RUN bash -c 'for py_include in /usr/include/python*; do ln -s $py_include /usr/local/include; done'

# Workaround for 'Cannot lod libmkl_acx2.so or libmkl_def.so', learnt from:
#     https://software.intel.com/en-us/forums/intel-math-kernel-library/topic/748309
ENV LD_PRELOAD=/opt/intel/mkl/lib/intel64/libmkl_def.so:/opt/intel/mkl/lib/intel64/libmkl_avx2.so:/opt/intel/mkl/lib/intel64/libmkl_core.so:/opt/intel/mkl/lib/intel64/libmkl_intel_lp64.so:/opt/intel/mkl/lib/intel64/libmkl_intel_thread.so:/opt/intel/lib/intel64_lin/libiomp5.so

# Add user as building software as root is just **not a good idea**
RUN useradd -m user
RUN mkdir -p /usr/local/src && chmod -R 777 /usr/local/src

# Set flags
ENV CC=/usr/bin/cc CXX=/usr/bin/c++ CFLAGS="-flto" CXXFLAGS="-flto"

# ... Now build the software!
FROM Configuration AS Build

## Install su-exec to replace sudo
RUN wget --progress=dot https://github.com/NobodyXu/su-exec/releases/download/v0.3/su-exec -O /usr/local/bin/su-exec
RUN chmod a+xs /usr/local/bin/su-exec

USER user
RUN git clone https://github.com/facebookresearch/faiss /usr/local/src/faiss
WORKDIR /usr/local/src/faiss

RUN LDFLAGS=-L/opt/intel/mkl/lib/intel64/ ./configure --without-cuda

RUN make -j $(nproc)
RUN make -C python -j $(nproc)

RUN make test

RUN su-exec root:root make install
RUN su-exec root:root make -C python install

WORKDIR /
# Move to another directory for coping and chowning in latest
RUN su-exec root:root mv /usr/local/src/faiss /home/user/faiss

## Remove su-exec
RUN su-exec root:root rm /usr/local/bin/su-exec

RUN rm -rf /tmp/*

FROM debian:buster AS Installed

COPY --from=Configuration / /
COPY --from=Build /usr/local/ /usr/local/

ENV LD_PRELOAD=/opt/intel/mkl/lib/intel64/libmkl_def.so:/opt/intel/mkl/lib/intel64/libmkl_avx2.so:/opt/intel/mkl/lib/intel64/libmkl_core.so:/opt/intel/mkl/lib/intel64/libmkl_intel_lp64.so:/opt/intel/mkl/lib/intel64/libmkl_intel_thread.so:/opt/intel/lib/intel64_lin/libiomp5.so

USER user

FROM Installed AS with-src
COPY --from=Build --chown=user:user /home/user/faiss /usr/local/src/faiss/
WORKDIR /usr/local/src/faiss
