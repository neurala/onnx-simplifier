FROM docker.io/library/ubuntu:focal as buildbase

ENV PYTHON_ROOT=/opt/Python3
ARG PYTHON_VERSION=3.9.23
ARG PYTHON_URL=https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz

RUN apt-get update && \
    apt-get install -y \
        software-properties-common \
        apt-transport-https \
        wget

# NOTE:2023-06-14:jgerity:build our own Python 3.9
# this list of dependencies adapted from https://devguide.python.org/getting-started/setup-building/#linux
RUN apt install -y build-essential pkg-config \
      libbz2-dev libffi-dev liblzma-dev \
      libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
      lzma lzma-dev uuid-dev tk-dev zlib1g-dev && \
    wget -O /tmp/Python.tgz ${PYTHON_URL} && \
    cd /tmp && tar --strip-components=1 -xf /tmp/Python.tgz &&\
   ./configure  \
            --enable-shared \
            --prefix=${PYTHON_ROOT} && \
   make -j$(nproc) && make install && \
   ldconfig && \
   cd /tmp && rm -fr /tmp/Python* && \
    # NOTE:2023-06-16:jgerity:Boost doesn't know about `pythonX.Ym`, we need to help it out with a symlink
    ln -s ${PYTHON_ROOT}/include/python3.9m ${PYTHON_ROOT}/include/python3.9

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PYTHON_ROOT}/lib

# NOTE:2024-09-03:jgerity:We install our own CMake to be sure that Python is located correctly when building Boost. This
# was a mitigation for an old version in Ubuntu 18.04 and *may* not be necessary in Ubuntu 20.04, but I haven't checked.
# Let's go ahead and keep it for now, but this can certainly be removed if we upgrade to a distro version that has this
# version of CMake or newer.
RUN \
    wget -O /tmp/cmake-3.31.5-Linux-x86_64.sh https://github.com/Kitware/CMake/releases/download/v3.31.5/cmake-3.31.5-Linux-x86_64.sh && \
    bash /tmp/cmake-3.31.5-Linux-x86_64.sh --skip-license --prefix=/usr && \
    rm -f /tmp/cmake-3.31.5-Linux-x86_64.sh
