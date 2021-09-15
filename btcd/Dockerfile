ARG ARCH=amd64
FROM golang:1.14-alpine3.12 AS build-container
USER root
ENV GO111MODULE=on
WORKDIR /root
RUN apk add git && git clone -b master https://github.com/btcsuite/btcd.git
WORKDIR /root/btcd
#REF: pin to v0.22.0-beta - update as needed
#REF: https://github.com/btcsuite/btcd/releases
ARG BTCD_VERSION=63438c6d3661a7dec09013f7731035abdf1eb4bc
RUN git fetch --all && git checkout ${BTCD_VERSION}
RUN set -ex \
  && if [ "${ARCH}" = "amd64" ]; then export GOARCH=amd64; fi \
  && if [ "${ARCH}" = "arm32v7" ]; then export GOARCH=arm; fi \
  && if [ "${ARCH}" = "arm64v8" ]; then export GOARCH=arm64; fi \
  && echo "Compiling for $GOARCH" \
  && go install -v . ./cmd/...

FROM alpine:3.12

COPY --from=build-container /go/bin /bin
#EXPOSE 8332 8333 28332 28333 28334 38332 38333 38334
EXPOSE 38334
ENTRYPOINT ["btcd","--signet","addpeer=104.131.10.218:38333","txindex=1","nodnsseed=1","whitelist=0.0.0.0/0"]
#,"signetchallenge=512102ee856c56a5aaadd1656f849bafa4c9dacc86a2878fe546c6189185f842ae2c1851ae"]
