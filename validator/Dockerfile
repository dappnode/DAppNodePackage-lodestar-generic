ARG UPSTREAM_VERSION

FROM chainsafe/lodestar:${UPSTREAM_VERSION}

ARG NETWORK
ARG STAKER_SCRIPTS_VERSION

COPY api-token.txt /var/lib/data/validator-db/api-token.txt
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV DATA_DIR=/var/lib/data \
    LOG_FILE=/var/lib/data/validator.log \
    NETWORK=${NETWORK} \
    STAKER_SCRIPTS_URL=https://raw.githubusercontent.com/dappnode/staker-package-scripts/${STAKER_SCRIPTS_VERSION}

ADD ${STAKER_SCRIPTS_URL}/consensus-tools.sh ${STAKER_SCRIPTS_URL}/common-tools.sh /etc/profile.d/

RUN chmod +x /usr/local/bin/entrypoint.sh /etc/profile.d/consensus-tools.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]