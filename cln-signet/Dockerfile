FROM elementsproject/lightningd:v0.10.2 as playground-cln
LABEL org.opencontainers.image.authors="Jonathan Thomson"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.source="https://github.com/PLEBNET-PLAYGROUND/plebnet-playground-docker"

# Define a root volume for data persistence
VOLUME /root/.lightning

# Expose lightningd ports
EXPOSE 9736

COPY docker-entrypoint.sh /usr/local/etc/entrypoint.sh
ENTRYPOINT ["/usr/local/etc/entrypoint.sh"]

# Specify the start command and entrypoint as the c-lightning daemon
CMD ["lightningd"]
