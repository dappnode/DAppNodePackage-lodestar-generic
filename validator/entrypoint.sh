#!/bin/sh

SUPPORTED_NETWORKS="gnosis holesky mainnet"
MEVBOOST_FLAG="--builder"
SKIP_MEVBOOST_URL="true"
CLIENT="lodestar"

# shellcheck disable=SC1091
. /etc/profile

run_validator() {
    echo "[INFO - entrypoint] Running validator service"

    # shellcheck disable=SC2086
    exec ${CLIENT_BIN} \
        validator \
        --network="${NETWORK}" \
        --suggestedFeeRecipient="${FEE_RECIPIENT}" \
        --graffiti="${GRAFFITI}" \
        --dataDir="${DATA_DIR}" \
        --keymanager true \
        --keymanager.authEnabled true \
        --keymanager.port 3500 \
        --keymanager.address 0.0.0.0 \
        --metrics \
        --metrics.port 5064 \
        --metrics.address 0.0.0.0 \
        --externalSigner.url="${WEB3SIGNER_API_URL}" \
        --doppelgangerProtection="${DOPPELGANGER_PROTECTION}" \
        --beaconNodes="${BEACON_API_URL}" \
        --logLevel="${LOG_LEVEL}" \
        --logFileLevel=debug \
        --logFileDailyRotate 5 \
        --logFile "${DATA_DIR}/validator.log" ${EXTRA_OPTS}
}

format_graffiti
set_validator_config_by_network "${NETWORK}" "${SUPPORTED_NETWORKS}" "${CLIENT}"
set_mevboost_flag "${MEVBOOST_FLAG}" "${SKIP_MEVBOOST_URL}" # MEV-Boost: https://chainsafe.github.io/lodestar/usage/mev-integration/
run_validator
