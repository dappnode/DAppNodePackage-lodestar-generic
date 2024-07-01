ARG UPSTREAM_VERSION

FROM chainsafe/lodestar:${UPSTREAM_VERSION}

ARG NETWORK
ARG STAKER_SCRIPTS_VERSION

COPY api-token.txt /var/lib/data/validator-db/api-token.txt
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ADD https://raw.githubusercontent.com/dappnode/staker-package-scripts/${STAKER_SCRIPTS_VERSION}/consensus-tools.sh /usr/local/bin/consensus-tools.sh

ENV DATA_DIR=/var/lib/data \
    LOG_FILE=/var/lib/data/validator.log \
    NETWORK=${NETWORK}

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]