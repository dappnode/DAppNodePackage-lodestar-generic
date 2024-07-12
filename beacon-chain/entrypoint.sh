#!/bin/sh

SUPPORTED_NETWORKS="gnosis holesky mainnet"
CHECKPOINT_SYNC_FLAG="--checkpointSync"
MEVBOOST_FLAGS="--builder --builder.url"

# shellcheck disable=SC1091 # Path is relative to the Dockerfile
. /etc/profile

run_beacon() {
    echo "[INFO - entrypoint] Running beacon node"

    # shellcheck disable=SC2086 # (EXTRA_OPTS may be empty)
    exec ${CLIENT_BIN} \
        beacon \
        --network="${NETWORK}" \
        --suggestedFeeRecipient="${FEE_RECIPIENT}" \
        --jwt-secret="${JWT_FILE_PATH}" \
        --execution.urls="${ENGINE_API_URL}" \
        --dataDir="${DATA_DIR}" \
        --rest \
        --rest.address 0.0.0.0 \
        --rest.port "${BEACON_API_PORT}" \
        --port "${P2P_PORT}" \
        --metrics \
        --metrics.port 8008 \
        --metrics.address 0.0.0.0 \
        --logFile "${DATA_DIR}/beacon.log" \
        --logLevel="${LOG_LEVEL}" \
        --logFileLevel=debug \
        --logFileDailyRotate 5 ${EXTRA_OPTS}
}

set_beacon_config_by_network "${NETWORK}" "${SUPPORTED_NETWORKS}"
set_checkpointsync_url "${CHECKPOINT_SYNC_FLAG}" "${CHECKPOINT_SYNC_URL}"
set_mevboost_flag "${MEVBOOST_FLAGS}" # MEV-Boost: https://chainsafe.github.io/lodestar/usage/mev-integration/
run_beacon
