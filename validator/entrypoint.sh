#!/bin/sh

# shellcheck disable=SC1091
. /etc/profile

run_validator() {
    echo "[INFO - entrypoint] Running validator node"

    # shellcheck disable=SC2086
    exec node /usr/app/node_modules/.bin/lodestar \
        validator \
        --network="${NETWORK}" \
        --suggestedFeeRecipient="${FEE_RECIPIENT_ADDRESS}" \
        --graffiti="${GRAFFITI}" \
        --dataDir="${DATA_DIR}" \
        --keymanager true \
        --keymanager.authEnabled true \
        --keymanager.port 3500 \
        --keymanager.address 0.0.0.0 \
        --metrics \
        --metrics.port 5064 \
        --metrics.address 0.0.0.0 \
        --externalSigner.url="${HTTP_WEB3SIGNER}" \
        --doppelgangerProtection="${DOPPELGANGER_PROTECTION}" \
        --beaconNodes="${BEACON_NODE_ADDR}" \
        --logLevel="${DEBUG_LEVEL}" \
        --logFileLevel=debug \
        --logFileDailyRotate 5 \
        --logFile /var/lib/data/validator.log ${EXTRA_OPTS}
}

format_graffiti
set_mevboost_flag "--builder" "true" # MEV-Boost: https://chainsafe.github.io/lodestar/usage/mev-integration/
run_validator
