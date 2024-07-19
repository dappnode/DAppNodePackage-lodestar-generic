#!/bin/sh

SUPPORTED_NETWORKS="gnosis holesky mainnet"
CHECKPOINT_SYNC_FLAG="--checkpointSyncUrl"
MEVBOOST_FLAG_KEYS="--builder --builder.url"

# shellcheck disable=SC1091 # Path is relative to the Dockerfile
. /etc/profile

ENGINE_URL=$(get_engine_api_url "${NETWORK}" "${SUPPORTED_NETWORKS}")
VALID_FEE_RECIPIENT=$(get_valid_fee_recipient "${FEE_RECIPIENT}")
CHECKPOINT_SYNC_FLAG=$(get_checkpoint_sync_flag "${CHECKPOINT_SYNC_FLAG}" "${CHECKPOINT_SYNC_URL}")
MEVBOOST_FLAG=$(get_mevboost_flag "${NETWORK}" "${MEVBOOST_FLAG_KEYS}")

echo "[INFO - entrypoint] Running beacon node"

# shellcheck disable=SC2086 # (EXTRA_OPTS may be empty)
exec ${CLIENT_BIN} \
    beacon \
    --network="${NETWORK}" \
    --suggestedFeeRecipient="${VALID_FEE_RECIPIENT}" \
    --jwt-secret="${JWT_FILE_PATH}" \
    --execution.urls="${ENGINE_URL}" \
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
    --logFileDailyRotate 5 ${CHECKPOINT_SYNC_FLAG} ${MEVBOOST_FLAG} ${EXTRA_OPTS}
