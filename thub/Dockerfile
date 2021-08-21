FROM apotdevin/thunderhub:v0.12.24 as playground-thunderhub
LABEL org.opencontainers.image.authors="Richard Safier"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.source="https://github.com/PLEBNET-PLAYGROUND/plebnet-playground-docker"


ENV THUB_DATA /data
VOLUME $THUB_DATA

COPY thubConfig.yaml /usr/local/etc/thubConfig.yaml 
COPY .env /usr/local/etc/.env

COPY docker-entrypoint.sh /usr/local/etc/entrypoint.sh

ENTRYPOINT ["/usr/local/etc/entrypoint.sh"]

CMD ["npm", "run", "start"]