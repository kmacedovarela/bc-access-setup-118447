#!/bin/bash

# Improved Configuration variables
EAP_VERSION="7.4.0"
BAMOE_VERSION="8.0.4"
JBOSS_HOME="jboss-eap-7.4"

current_path=$(pwd)

INSTALLERS_DIR="${current_path}/installers"
SUPPORT_DIR="${current_path}/support"
BASE_DIR="${current_path}/bamoe"

EAP_ZIP="${INSTALLERS_DIR}/jboss-eap-${EAP_VERSION}.zip"
BC_ZIP="${INSTALLERS_DIR}/bamoe-${BAMOE_VERSION}-business-central-eap7-deployable.zip"
KS_ZIP="${INSTALLERS_DIR}/bamoe-${BAMOE_VERSION}-kie-server-ee8.zip"

BC_HOME="${BASE_DIR}/bc"
KS_HOME="${BASE_DIR}/ks"

BC_EAP="${BC_HOME}/${JBOSS_HOME}"
KS_EAP="${KS_HOME}/${JBOSS_HOME}"

BC_STANDALONE_CONF="${BC_EAP}/bin/standalone.conf"
KS_STANDALONE_CONF="${KS_EAP}/bin/standalone.conf"

TMP_DIR="${SUPPORT_DIR}/tmp"

DEPLOY_DIR="/standalone/deployments"

BC_CLI="${SUPPORT_DIR}/configure-bc.cli"
KS_CLI="${SUPPORT_DIR}/configure-ks.cli"

# Enhanced helper functions
info() {
    echo -e "\033[1;32mINFO: $1\033[0m"
}

warn() {
    echo -e "\033[1;33mWARN: $1\033[0m"
}

error_exit() {
    echo -e "\033[1;31mERROR: $1\033[0m" >&2
    exit 1
}


# Cleanup and preparation
info "Preparing environment..."
rm -rf "${BASE_DIR}" "${TMP_DIR}"
mkdir -p "${BC_HOME}" "${KS_HOME}" "${TMP_DIR}" || error_exit "Failed to create directories."

# Installers extraction & EAP Patch
info "Unzipping EAP..."
unzip -qo "${EAP_ZIP}" -d "${TMP_DIR}" || error_exit "Failed to unzip EAP."
info "Applying EAP patch..."
"${TMP_DIR}/${JBOSS_HOME}/bin/jboss-cli.sh" "patch apply ${INSTALLERS_DIR}/jboss-eap-7.4.4-patch.zip" || error_exit "Failed to apply EAP patch."

info "Unzipping Business Central..."
unzip -qo "${BC_ZIP}" -d "${TMP_DIR}" || error_exit "Failed to unzip Business Central."
info "Unzipping KIE Server..."
unzip -qo "${KS_ZIP}" -d "${TMP_DIR}" || error_exit "Failed to unzip KIE Server."

# Copying EAP directories
info "Copying EAP directories for BC and KS..."
cp -Rf "${TMP_DIR}/${JBOSS_HOME}" "${BC_HOME}" || error_exit "Failed to copy EAP for BC."
cp -Rf "${TMP_DIR}/${JBOSS_HOME}" "${KS_HOME}" || error_exit "Failed to copy EAP for KS."

# Configuration adjustments
info "Adjusting standalone configurations..."
echo 'JAVA_OPTS="$JAVA_OPTS -Djboss.server.default.config=standalone-full.xml"' >> "$BC_STANDALONE_CONF"
echo 'JAVA_OPTS="$JAVA_OPTS -Djboss.server.default.config=standalone-full.xml -Djboss.socket.binding.port-offset=100"' >> "$KS_STANDALONE_CONF"

# Running CLI scripts for configuration
info "Configuring Business Central..."
"${BC_EAP}/bin/jboss-cli.sh" --file="${BC_CLI}" --controller=localhost:9990 || error_exit "Failed to configure Business Central."
info "Business Central configured successfully."

# Adding default spaces for testing the patch
info "Adding spaces for testing..."
mkdir -p "$BC_EAP/standalone/data/kie/git"
cp -Rf "${SUPPORT_DIR}/git" "$BC_EAP/standalone/data/kie/" || error_exit "Failed to configure Business Central."
info "Spaces imported."


info "Configuring KIE Server..."
"${KS_EAP}/bin/jboss-cli.sh" --file="${KS_CLI}" --controller=localhost:10090 || error_exit "Failed to configure KIE Server."
info "KIE Server configured successfully."

info "Installation and configuration completed successfully."
