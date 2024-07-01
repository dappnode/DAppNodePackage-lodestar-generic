ARG UPSTREAM_VERSION

FROM chainsafe/lodestar:${UPSTREAM_VERSION}

ARG NETWORK
ARG STAKER_SCRIPTS_VERSION

# curl is required to check if mev-boost is running
RUN apk update && apk add --no-cache curl

COPY jwtsecret.hex /jwtsecret
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ADD https://raw.githubusercontent.com/dappnode/staker-package-scripts/${STAKER_SCRIPTS_VERSION}/consensus-tools.sh /usr/local/bin/consensus-tools.sh

ENV JWT_SECRET_FILE=/jwtsecret \
    DATA_DIR=/var/lib/data \
    NETWORK=${NETWORK}

EXPOSE $BEACON_API_PORT

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
