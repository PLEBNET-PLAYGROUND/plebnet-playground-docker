# Also see LNBits install instructions:
# https://github.com/lnbits/lnbits-legend/blob/main/docs/guide/installation.md

# Install build deps, python3.8 from ubuntu 20.04 works for lnbits
FROM ubuntu:20.04
RUN apt-get -y update
RUN apt-get install -y --no-install-recommends build-essential pkg-config 
RUN apt install -y python3-pip postgresql-client
RUN pip3 install wheel
RUN apt-get -y install git libffi-dev libpq-dev 

# Copy in app source
WORKDIR /app

# clone repository
RUN git clone https://github.com/lnbits/lnbits-legend /app/lnbits
WORKDIR /app/lnbits
RUN git checkout 11006ef7ed34e226629bad4f4b614e21c4df1ec4


# Install runtime deps
USER root
RUN pip3 install --upgrade pip
RUN pip3 install -r /app/lnbits/requirements.txt
RUN mkdir -p /app/lnbits/data


# Install c-lightning specific deps
RUN pip3 install pylightning

# Install LND specific deps - has trouble installing
RUN pip3 install lndgrpc 
RUN pip3 install psycopg2


ENV LNBITS_PORT="5000"
ENV LNBITS_HOST="0.0.0.0"
EXPOSE 5000

ENV LNBITS_DATA_FOLDER="/data"
ENV LNBITS_DATABASE_URL="postgres://postgres:myPassword@playground-postgres:5432/lnbits"

COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh
COPY .env /usr/local/etc/.env
COPY lnbitsConfig.yaml /usr/local/etc/lnbitsConfig.yaml

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

WORKDIR /app/lnbits
CMD ["sh", "-c", "uvicorn lnbits.__main__:app --port $LNBITS_PORT --host $LNBITS_HOST"]
