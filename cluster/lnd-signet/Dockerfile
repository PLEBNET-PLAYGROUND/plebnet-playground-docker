FROM golang:1.16.3-alpine as builder

# Pass a tag, branch or a commit using build-arg.  This allows a docker
# image to be built from a specified Git state.  The default image
# will use the Git tip of master by default.
ARG BRANCH="tags/v0.14.2-beta"

# Force Go to use the cgo based DNS resolver. This is required to ensure DNS
# queries required to connect to linked containers succeed.
ENV GODEBUG netdns=cgo

# Install dependencies and build the binaries.
RUN apk add --no-cache --update alpine-sdk \
    git \
    make \
    gcc \
&&  git clone https://github.com/lightningnetwork/lnd /go/src/github.com/lightningnetwork/lnd \
&&  cd /go/src/github.com/lightningnetwork/lnd \
&&  git checkout "${BRANCH}" \
&&  make release-install

# Start a new, final image.
FROM alpine:3 as playground-lnd-signet

LABEL org.opencontainers.image.authors="Richard Safier"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.source="https://github.com/PLEBNET-PLAYGROUND/plebnet-playground-docker"

# Define a root volume for data persistence.
VOLUME /root/.lnd

# Expose lnd ports (p2p, rpc).
EXPOSE 9735 9911 10009

# Add utilities for quality of life and SSL-related reasons. We also require
# curl and gpg for the signature verification script.
RUN apk --no-cache add \
    bash \
    jq \
    ca-certificates \
    gnupg \
    curl

# Copy the binaries from the builder image.
COPY --from=builder /go/bin/lncli /bin/
COPY --from=builder /go/bin/lnd /bin/
COPY --from=builder /go/src/github.com/lightningnetwork/lnd/scripts/verify-install.sh /

# Store the SHA256 hash of the binaries that were just produced for later
# verification.
RUN sha256sum /bin/lnd /bin/lncli > /shasums.txt

COPY docker-entrypoint.sh /usr/local/etc/entrypoint.sh
COPY docker-initwalletcreate.sh /usr/local/etc/docker-initwalletcreate.sh
COPY docker-fixmissingalias.sh /usr/local/etc/docker-fixmissingalias.sh
ENTRYPOINT ["/usr/local/etc/entrypoint.sh"]

# Specify the start command and entrypoint as the lnd daemon.
CMD ["lnd"]
