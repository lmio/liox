#!/usr/bin/env bash

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <user_list>"
    exit 1
fi

FIRST_USER="$1"
shift
OTHER_USERS=("$@")
EXTENSION_NAME="ms-vscode.cpptools-extension-pack"

echo "Will install vscode extension: '$EXTENSION_NAME'"
echo "Will install from internet for user: ${FIRST_USER}"
if [ "${#OTHER_USERS[@]}" -ne 0 ]; then
    echo "Will install from cached VSIXs for users: ${OTHER_USERS[@]}"
fi

cleanup_tmpdir() {
    echo "Removing ${VSIX_TMP_DIR}"
    rm -rf "${VSIX_TMP_DIR}"
}

VSIX_TMP_DIR="$(mktemp -d /tmp/vscode-vsix.XXXXXXXXX)"
trap cleanup_tmpdir EXIT

echo "Installing from internet for ${FIRST_USER}"
sudo -u "${FIRST_USER}" code --install-extension ${EXTENSION_NAME}
install_args=()
final_install_args=()
for f in "/home/${FIRST_USER}/.config/Code/CachedExtensionVSIXs/"*; do
    vsix_file="${VSIX_TMP_DIR}/$(basename "${f}").vsix"
    mv "${f}" "${vsix_file}"
    if [[ "$(basename "${f}")" == "${EXTENSION_NAME}"* ]]; then
        final_install_args+=(--install-extension "${vsix_file}")
    else
        install_args+=(--install-extension "${vsix_file}")
    fi
done
chmod 777 "${VSIX_TMP_DIR}"
for user in "${OTHER_USERS[@]}"; do
    echo "Installing from VSIXs for ${user}"
    sudo -u "${user}" code ${install_args[@]}
    sudo -u "${user}" code ${final_install_args[@]}
done
