#!/bin/sh

SUPPORTED_NETWORKS="gnosis holesky mainnet"
MEVBOOST_FLAG_KEY="--builder"
SKIP_MEVBOOST_URL="true"
CLIENT="lodestar"

# shellcheck disable=SC1091
. /etc/profile

VALID_GRAFFITI=$(get_valid_graffiti "${GRAFFITI}")
VALID_FEE_RECIPIENT=$(get_valid_fee_recipient "${FEE_RECIPIENT}")
SIGNER_API_URL=$(get_signer_api_url "${NETWORK}" "${SUPPORTED_NETWORKS}")
BEACON_API_URL=$(get_beacon_api_url "${NETWORK}" "${SUPPORTED_NETWORKS}" "${CLIENT}")
MEVBOOST_FLAG=$(get_mevboost_flag "${MEVBOOST_FLAG_KEY}" "${SKIP_MEVBOOST_URL}")

echo "[INFO - entrypoint] Running validator service"

# shellcheck disable=SC2086
exec ${CLIENT_BIN} \
    validator \
    --network="${NETWORK}" \
    --suggestedFeeRecipient="${VALID_FEE_RECIPIENT}" \
    --graffiti="${VALID_GRAFFITI}" \
    --dataDir="${DATA_DIR}" \
    --keymanager true \
    --keymanager.authEnabled true \
    --keymanager.port 3500 \
    --keymanager.address 0.0.0.0 \
    --metrics \
    --metrics.port 5064 \
    --metrics.address 0.0.0.0 \
    --externalSigner.url="${SIGNER_API_URL}" \
    --doppelgangerProtection="${DOPPELGANGER_PROTECTION}" \
    --beaconNodes="${BEACON_API_URL}" \
    --logLevel="${LOG_LEVEL}" \
    --logFileLevel=debug \
    --logFileDailyRotate 5 \
    --logFile "${DATA_DIR}/validator.log" ${MEVBOOST_FLAG} ${EXTRA_OPTS}
