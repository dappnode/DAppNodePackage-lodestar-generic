ARG UPSTREAM_VERSION
ARG NETWORK

FROM chainsafe/lodestar:${UPSTREAM_VERSION}

# curl is required to check if mev-boost is running
RUN apk update && apk add --no-cache curl

COPY jwtsecret.hex /jwtsecret
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV JWT_SECRET_FILE=/jwtsecret \
    DATA_DIR=/var/lib/data \
    NETWORK=${NETWORK}

EXPOSE $BEACON_API_PORT

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
