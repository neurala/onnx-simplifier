FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies for Python and other tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        wget \
        ca-certificates \
        libssl-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libffi-dev \
        liblzma-dev \
        zlib1g-dev \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install CMake
RUN cd /tmp && \
    wget -q https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3-linux-x86_64.tar.gz && \
    tar -xzf cmake-3.28.3-linux-x86_64.tar.gz && \
    mv cmake-3.28.3-linux-x86_64 /opt/cmake && \
    ln -sf /opt/cmake/bin/cmake /usr/local/bin/cmake && \
    ln -sf /opt/cmake/bin/ctest /usr/local/bin/ctest && \
    ln -sf /opt/cmake/bin/cpack /usr/local/bin/cpack && \
    rm -rf /tmp/cmake-3.28.3-linux-x86_64.tar.gz cmake-3.28.3-linux-x86_64 && \
    cmake --version

RUN cd /tmp && \
    wget -q https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz && \
    tar -xzf Python-3.10.13.tgz && \
    cd Python-3.10.13 && \
    ./configure \
        --enable-optimizations \
        --enable-shared \
        --prefix=/usr/local \
        --with-ensurepip=install \
        LDFLAGS="-Wl,-rpath /usr/local/lib" && \
    make -j$(nproc) && \
    make altinstall && \
    cd / && \
    rm -rf /tmp/Python-3.10.13* && \
    ln -sf /usr/local/bin/python3.10 /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/python3.10 /usr/local/bin/python && \
    ln -sf /usr/local/bin/pip3.10 /usr/local/bin/pip3 && \
    ln -sf /usr/local/bin/pip3.10 /usr/local/bin/pip

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

WORKDIR /app

COPY requirements.txt .

RUN python3.10 -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    python3.10 -m pip install --no-cache-dir -r requirements.txt

COPY onnxsim ./onnxsim
COPY CMakeLists.txt .
COPY setup.py .
COPY VERSION .
COPY cmake ./cmake
COPY README.md .
COPY third_party ./third_party

RUN python3.10 setup.py bdist_wheel

CMD ["sh", "-c", "if [ -d /output ] && [ -w /output ]; then cp -r /app/dist/* /output/ && echo 'Copied wheels to /output:' && ls -la /output/; else echo 'Built wheels in /app/dist:'; ls -la /app/dist/; fi"]
