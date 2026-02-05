FROM ubuntu:20.04


ENV PYTHON_INSTALL_VERSION=3.10.13
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
    wget -q https://www.python.org/ftp/python/${PYTHON_INSTALL_VERSION}/Python-${PYTHON_INSTALL_VERSION}.tgz && \
    tar -xzf Python-${PYTHON_INSTALL_VERSION}.tgz && \
    cd Python-${PYTHON_INSTALL_VERSION} && \
    ./configure \
        --enable-optimizations \
        --enable-shared \
        --prefix=/usr/local \
        --with-ensurepip=install \
        LDFLAGS="-Wl,-rpath /usr/local/lib" && \
    make -j$(nproc) && \
    make altinstall && \
    cd / && \
    rm -rf /tmp/Python-${PYTHON_INSTALL_VERSION}* && \

    ln -sf /usr/local/bin/python3 /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/pip3 /usr/local/bin/pip3

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

WORKDIR /app

COPY requirements.txt .

RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    python3 -m pip install --no-cache-dir -r requirements.txt

COPY onnxsim ./onnxsim
COPY CMakeLists.txt .
COPY setup.py .
COPY VERSION .
COPY cmake ./cmake
COPY README.md .
COPY third_party ./third_party

CMD ["sh", "-c", "if [ -d /output ] && [ -w /output ]; then OUTPUT_DIR=/output; else OUTPUT_DIR=/app/dist; fi && python3 setup.py bdist_wheel --dist-dir \"$OUTPUT_DIR\" && ls -la \"$OUTPUT_DIR\""]
