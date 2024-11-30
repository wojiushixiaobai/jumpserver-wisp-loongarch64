ARG GO_VERSION=1.23

FROM cr.loongnix.cn/library/golang:${GO_VERSION}-buster AS builder

ARG GORELEASER_VERSION=latest

RUN --mount=type=cache,target=/go/pkg/mod \
    set -ex; \
    go install github.com/goreleaser/goreleaser/v2@${GORELEASER_VERSION}

ARG VERSION

ARG WORKDIR=/opt/wisp

RUN set -ex; \
    git clone -b ${VERSION} --depth=1 https://github.com/jumpserver/wisp ${WORKDIR}

ADD .goreleaser.yml /opt/.goreleaser.yml
WORKDIR ${WORKDIR}

RUN --mount=type=cache,target=/go/pkg/mod \
    set -ex; \
    export GOVERSION=$(go version | awk '{print $3}'); \
    goreleaser --config /opt/.goreleaser.yml release --skip=publish --clean

FROM cr.loongnix.cn/library/debian:buster-slim

ARG WORKDIR=/opt/wisp

WORKDIR ${WORKDIR}

COPY --from=builder ${WORKDIR}/dist ${WORKDIR}/dist

VOLUME /dist

CMD cp -rf dist/* /dist/