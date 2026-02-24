FROM alpine:latest

RUN apk add --no-cache \
    build-base \
    clang \
    cmake \
    ninja-build \
    python3 \
    git \
    bash \
    curl \
    tar \
    xz \
    linux-headers && \
    ln -s /usr/lib/ninja-build/bin/ninja /usr/local/bin/ninja

# sccache
ARG SCCACHE_VERSION=v0.12.0
RUN ARCH=$(uname -m) && \
    curl -L "https://github.com/mozilla/sccache/releases/download/${SCCACHE_VERSION}/sccache-${SCCACHE_VERSION}-${ARCH}-unknown-linux-musl.tar.gz" \
    -o sccache.tar.gz && \
    tar xzf sccache.tar.gz && \
    mv sccache-${SCCACHE_VERSION}-${ARCH}-unknown-linux-musl/sccache /usr/local/bin/ && \
    chmod +x /usr/local/bin/sccache && \
    rm -rf sccache.tar.gz sccache-${SCCACHE_VERSION}-${ARCH}-unknown-linux-musl

WORKDIR /work

ENV CC=clang
ENV CXX=clang++
ENV SCCACHE_CACHE_SIZE="5G"

CMD ["/bin/bash"]
