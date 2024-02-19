# Product versions
export EAP_VERSION=7.4.0
export BAM_VERSION=8.0.3

# File names
export EAP_FILE=jboss-eap-${EAP_VERSION}.zip
export BC_FILE=bamoe-${BAM_VERSION}-business-central-eap7-deployable.zip
export KS_FILE=bamoe-${BAM_VERSION}-kie-server-ee8.zip

# Paths
export INSTALL_DIR=./installs
export BC_HOME=./bc-eap
export KS_HOME=./ks-eap

# Repo info
export AUTHORS="IBM Community Contributors"
export PRODUCT="IBM Business Automation Manager Open Editions"
export REPO="https://github.com/jbossdemocentral/rhpam7-install-demo.git"

declare -A eap
eap[file]="jboss-eap-7.4.0.zip"
eap[version]="7.4.0"

declare -A bc
bc[file]="bamoe-8.0.3-business-central-eap7-deployable.zip"
bc[version]="8.0.3"

src_dir="./installs"

# Access values
echo "${products[eap][0]}" # jboss-eap-7.4.0.zip
echo "${products[eap][1]}" # 7.4.0
