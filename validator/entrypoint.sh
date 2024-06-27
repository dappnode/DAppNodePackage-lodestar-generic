#!/bin/sh

format_graffiti() {
    # Save current locale settings
    oLang="$LANG" oLcAll="$LC_ALL"

    # Set locale to C for consistent behavior in string operations
    LANG=C LC_ALL=C

    if [ -z "$GRAFFITI" ]; then
        VALID_GRAFFITI=""
    else
        # Truncate GRAFFITI to 32 characters if it is set
        VALID_GRAFFITI=$(echo "$GRAFFITI" | cut -c 1-32)
    fi

    echo "[INFO] Using graffiti: $VALID_GRAFFITI"

    # Restore locale settings
    LANG="$oLang" LC_ALL="$oLcAll"
}

# MEV-Boost: https://chainsafe.github.io/lodestar/usage/mev-integration/
set_mev_boost_flag() {

    network_uppercase=$(echo "${NETWORK}" | tr '[:lower:]' '[:upper:]')
    mevboost_enabled_var="_DAPPNODE_GLOBAL_MEVBOOST_${network_uppercase}"

    # Using eval to check and assign the variable, ensuring it's not unbound
    eval "mevboost_enabled=\${${mevboost_enabled_var}:-false}"

    # shellcheck disable=SC2154
    if [ "${mevboost_enabled}" = "true" ]; then
        echo "[INFO] MEV Boost is enabled"
        EXTRA_OPTS="--builder ${EXTRA_OPTS}"
    else
        echo "[INFO] MEV Boost is disabled"
    fi
}

format_graffiti

set_mev_boost_flag

exec node /usr/app/node_modules/.bin/lodestar \
    validator \
    --network="${NETWORK}" \
    --suggestedFeeRecipient="${FEE_RECIPIENT_ADDRESS}" \
    --graffiti="${VALID_GRAFFITI}" \
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
    --logFile /var/lib/data/validator.log \
    "${EXTRA_OPTS}"
