ARG GOLANG_VERSION=1.20.2
FROM golang:${GOLANG_VERSION}-bullseye as builder
ARG GETH_VERSION=v1.11.5
ENV GETH_VERSION=${GETH_VERSION}
RUN git clone --filter=tree:0 -b ${GETH_VERSION} https://github.com/ethereum/go-ethereum.git \
    && cd go-ethereum \
    && make all

FROM mcr.microsoft.com/devcontainers/base:bullseye as devcontainer
ARG GETH_VERSION=v1.11.5
ENV GETH_VERSION=${GETH_VERSION}
COPY --from=builder /go/go-ethereum/build/bin /opt/go-ethereum-${GETH_VERSION}
RUN echo "export PATH="$"PATH:/opt/go-ethereum-${GETH_VERSION}" > /etc/profile.d/99-add-path-to-geth.sh \
    && chmod a+x /etc/profile.d/99-add-path-to-geth.sh
