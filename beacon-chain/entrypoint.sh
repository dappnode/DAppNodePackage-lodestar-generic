#!/bin/sh

SCRIPTS_DIR=$(dirname "$0")
CONSENSUS_TOOLS_SCRIPT="${SCRIPTS_DIR}/consensus-tools.sh"

if [ ! -f "$CONSENSUS_TOOLS_SCRIPT" ]; then
    echo "consensus-tools.sh not found"
    exit 1
fi

# shellcheck disable=SC1090 # Shellcheck can't find the file dynamically
. "${CONSENSUS_TOOLS_SCRIPT}"

handle_network() {
    case "$NETWORK" in
    "gnosis") set_network_specific_config 19012 ;;
    "holesky") set_network_specific_config 9612 ;;
    "mainnet") set_network_specific_config 9112 ;;
    *)
        echo "Unsupported network: $NETWORK"
        exit 1
        ;;
    esac
}

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

handle_network
set_checkpointsync_url "--checkpointSyncUrl"
set_mevboost "--builder --builder.url" # MEV-Boost: https://chainsafe.github.io/lodestar/usage/mev-integration/
run_beacon
