# see correct LNBits install instructions:
# https://github.com/lnbits/lnbits-legend/blob/main/docs/guide/installation.md

# Build image
FROM python:3.7-slim as builder

# Install build deps
FROM ubuntu:latest
RUN apt-get -y update
RUN apt-get install -y --no-install-recommends build-essential pkg-config 
RUN apt install -y python3-pip
RUN pip install wheel
RUN apt-get -y install git

# Copy in app source
WORKDIR /app

# clone repository
RUN git clone https://github.com/lnbits/lnbits-legend /app/lnbits

# Install runtime deps
#USER root
RUN pip install -r /app/lnbits/requirements.txt
RUN mkdir -p /app/lnbits/data

# Install c-lightning specific deps
RUN pip install pylightning

# Install LND specific deps - has trouble installing
RUN pip install lndgrpc

# Run as non-root - doesn't seem to run as nonroot
USER 1000:1000
COPY --chown=1000:1000 . /app/lnbits

ENV LNBITS_PORT="5000"
ENV LNBITS_HOST="0.0.0.0"
EXPOSE 5000

ENV LNBITS_DATA_FOLDER="./data"
ENV LNBITS_DATABASE_URL="postgres://postgres:myPassword@localhost:5432/lnbits"

#COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh
#ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

WORKDIR /app/lnbits
CMD ["sh", "-c", "uvicorn lnbits.__main__:app --port $LNBITS_PORT --host $LNBITS_HOST"]
