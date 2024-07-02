#!/bin/sh

SUPPORTED_NETWORKS="gnosis holesky mainnet"
MEVBOOST_SUPPORTED_NETWORKS="mainnet holesky"

# shellcheck disable=SC1091 # Path is relative to the Dockerfile
. /etc/profile

run_beacon() {
    echo "[INFO - entrypoint] Running beacon node"

    # shellcheck disable=SC2086 # (EXTRA_OPTS may be empty)
    exec node --max-old-space-size="${MEMORY_LIMIT}" /usr/app/packages/cli/bin/lodestar \
        beacon \
        --network=mainnet \
        --suggestedFeeRecipient="${FEE_RECIPIENT_ADDRESS}" \
        --jwt-secret="${JWT_SECRET_FILE}" \
        --execution.urls="${HTTP_ENGINE}" \
        --dataDir="${DATA_DIR}" \
        --rest \
        --rest.address 0.0.0.0 \
        --rest.port "${BEACON_API_PORT}" \
        --port "${P2P_PORT}" \
        --metrics \
        --metrics.port 8008 \
        --metrics.address 0.0.0.0 \
        --logFile "${DATA_DIR}/beacon.log" \
        --logLevel="${DEBUG_LEVEL}" \
        --logFileLevel="${DEBUG_LEVEL}" \
        --logFileDailyRotate 5 ${EXTRA_OPTS:-}
}

set_consensus_config_by_network "${SUPPORTED_NETWORKS}"
set_checkpointsync_url "--checkpointSyncUrl" "${CHECKPOINT_SYNC_URL}"
set_mevboost_flag "${MEVBOOST_SUPPORTED_NETWORKS}" "--builder --builder.url" # MEV-Boost: https://chainsafe.github.io/lodestar/usage/mev-integration/
run_beacon
