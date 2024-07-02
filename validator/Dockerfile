ARG UPSTREAM_VERSION

FROM chainsafe/lodestar:${UPSTREAM_VERSION}

ARG NETWORK
ARG STAKER_SCRIPTS_VERSION

COPY api-token.txt /var/lib/data/validator-db/api-token.txt
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV DATA_DIR=/var/lib/data \
    LOG_FILE=/var/lib/data/validator.log \
    NETWORK=${NETWORK} \
    STAKER_SCRIPTS_URL=https://github.com/dappnode/staker-package-scripts/releases/download/${STAKER_SCRIPTS_VERSION}

ADD ${STAKER_SCRIPTS_URL}/consensus_tools.sh /etc/profile.d/

RUN chmod +rx /usr/local/bin/entrypoint.sh /etc/profile.d/consensus_tools.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]