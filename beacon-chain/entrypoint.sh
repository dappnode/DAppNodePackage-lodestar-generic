#!/bin/sh

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

set_network_specific_config() {
    P2P_PORT=$1

    echo "[INFO - entrypoint] Initializing $NETWORK specific config for client"

    set_execution_dnp

    set_engine_url
}

set_execution_dnp() {
    uppercase_network=$(echo "$NETWORK" | tr '[:lower:]' '[:upper:]')
    execution_dnp_var="_DAPPNODE_GLOBAL_EXECUTION_CLIENT_${uppercase_network}"
    eval "EXECUTION_DNP=\$$execution_dnp_var"
}

set_engine_url() {
    case "$EXECUTION_DNP" in
    *".public."*)
        # nethermind.public.dappnode.eth -> nethermind.public
        execution_subdomain=$(echo "$EXECUTION_DNP" | cut -d'.' -f1-2)
        ;;
    *)
        # geth.dnp.dappnode.eth -> geth
        execution_subdomain=$(echo "$EXECUTION_DNP" | cut -d'.' -f1)
        ;;
    esac

    HTTP_ENGINE="http://${execution_subdomain}.dappnode:8551"
}

set_checkpointsync_url() {
    if [ -n "$CHECKPOINT_SYNC_URL" ]; then
        echo "[INFO - entrypoint] Checkpoint sync URL is set to $CHECKPOINT_SYNC_URL"
        EXTRA_OPTS="${EXTRA_OPTS} --checkpointSyncUrl=${CHECKPOINT_SYNC_URL}"
    else
        echo "[WARN - entrypoint] Checkpoint sync URL is not set"
    fi
}

# MEV-Boost: https://chainsafe.github.io/lodestar/usage/mev-integration/
set_mev_boost_flag() {

    network_uppercase=$(echo "${NETWORK}" | tr '[:lower:]' '[:upper:]')
    mevboost_enabled_var="_DAPPNODE_GLOBAL_MEVBOOST_${network_uppercase}"

    # Using eval to check and assign the variable, ensuring it's not unbound
    eval "mevboost_enabled=\${${mevboost_enabled_var}:-false}"

    # shellcheck disable=SC2154
    if [ "${mevboost_enabled}" = "true" ]; then
        echo "[INFO - entrypoint] MEV Boost is enabled"
        set_mev_boost_url

        if is_mev_boost_available; then
            EXTRA_OPTS="--builder --builder.url=${MEVBOOST_URL} ${EXTRA_OPTS}"
        fi
    else
        echo "[INFO - entrypoint] MEV Boost is disabled"
    fi
}

set_mev_boost_url() {
    # If network is mainnet and MEV-Boost is enabled, set the MEV-Boost URL
    if [ "${NETWORK}" = "mainnet" ]; then
        MEVBOOST_URL="http://mev-boost.dappnode:18550"
    else
        MEVBOOST_URL="http://mev-boost-${NETWORK}.dappnode:18550"
    fi

    echo "[INFO - entrypoint] MEV Boost URL is set to $MEVBOOST_URL"
}

is_mev_boost_available() {
    if [ -z "${MEVBOOST_URL}" ]; then
        echo "[ERROR - entrypoint] MEV Boost URL is not set"
        return 1
    fi

    if curl --retry 5 --retry-delay 5 --retry-all-errors "${MEVBOOST_URL}"; then
        echo "[INFO - entrypoint] MEV Boost is available"
        return 0
    else
        echo "[ERROR - entrypoint] MEV Boost is enabled but the package at ${MEVBOOST_URL} is not reachable. Disabling MEV Boost..."
        curl -X POST -G 'http://my.dappnode/notification-send' \
            --data-urlencode 'type=danger' \
            --data-urlencode title="${MEVBOOST_URL} can not be reached" \
            --data-urlencode 'body=Make sure the MEV Boost DNP for this network is available and running'
        return 1
    fi
}

handle_network
set_checkpointsync_url
set_mev_boost_flag

exec node --max-old-space-size="${MEMORY_LIMIT}" /usr/app/node_modules/.bin/lodestar \
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
    --logFileDailyRotate 5 \
    "${EXTRA_OPTS}"
