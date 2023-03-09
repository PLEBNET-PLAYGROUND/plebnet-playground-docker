FROM debian:sid-slim as builder

ARG BITCOIN_VERSION=24.0.1
ARG TRIPLET=${TRIPLET}


#RUN apt-add-repository ppa:bitcoin/bitcoin && apt-get update && apt-get install bitcoin
#RUN /lib64/ld-linux-x86-64.so.2 /bin/chmod +x /bin/chmod

RUN  apt-get update && \
     apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu wget libc6

WORKDIR /tmp

# install bitcoin binaries
RUN BITCOIN_URL="https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-${TRIPLET}.tar.gz" && \
    BITCOIN_FILE="bitcoin-${BITCOIN_VERSION}-${TRIPLET}.tar.gz" && \
    BITCOIN_SHA_URL="https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS" && \
    wget -qO "${BITCOIN_FILE}" "${BITCOIN_URL}" && wget -qO SHA256SUMS.asc "${BITCOIN_SHA_URL}" && \
    grep "${BITCOIN_FILE}" SHA256SUMS.asc | sha256sum -c - && \
    mkdir -p bin && \
    tar -xzvf "${BITCOIN_FILE}" -C /tmp/bin --strip-components=2 "bitcoin-${BITCOIN_VERSION}/bin/bitcoin-cli" "bitcoin-${BITCOIN_VERSION}/bin/bitcoind" "bitcoin-${BITCOIN_VERSION}/bin/bitcoin-wallet" 

FROM debian:sid-slim as playground-bitcoin-signet

LABEL org.opencontainers.image.authors="Richard Safier"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.source="https://github.com/PLEBNET-PLAYGROUND/plebnet-playground-docker"

ENV BITCOIN_DIR /root/.bitcoin 

VOLUME $BITCOIN_DIR
EXPOSE 8332 8333 28332 28333 28334 38332 38333 38334

COPY --from=builder "/tmp/bin" /usr/local/bin

COPY blocknotify  /usr/local/bin/blocknotify
COPY walletnotify /usr/local/bin/walletnotify
COPY bitcoin.conf /usr/local/etc/bitcoin.conf
COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["bitcoind"]
