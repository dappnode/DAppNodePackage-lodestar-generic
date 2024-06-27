ARG UPSTREAM_VERSION
ARG NETWORK

FROM chainsafe/lodestar:${UPSTREAM_VERSION}

COPY api-token.txt /var/lib/data/validator-db/api-token.txt
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV DATA_DIR=/var/lib/data \
    LOG_FILE=/var/lib/data/validator.log \
    NETWORK=${NETWORK}

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]