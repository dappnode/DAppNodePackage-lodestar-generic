ARG UPSTREAM_VERSION

FROM chainsafe/lodestar:${UPSTREAM_VERSION}

ARG NETWORK
ARG STAKER_SCRIPTS_VERSION

COPY jwtsecret.hex /jwtsecret
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# curl is required to check if mev-boost is running
RUN apk update && apk add --no-cache curl

ENV JWT_SECRET_FILE=/jwtsecret \
    DATA_DIR=/var/lib/data \
    NETWORK=${NETWORK} \
    STAKER_SCRIPTS_URL=https://github.com/dappnode/staker-package-scripts/releases/download/${STAKER_SCRIPTS_VERSION}

ADD ${STAKER_SCRIPTS_URL}/consensus_tools.sh /etc/profile.d/

RUN chmod +rx /usr/local/bin/entrypoint.sh /etc/profile.d/consensus_tools.sh

EXPOSE $BEACON_API_PORT

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
