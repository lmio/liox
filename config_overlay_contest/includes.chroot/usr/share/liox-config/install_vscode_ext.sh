#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
	echo "Please run as root"
	exit
fi

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <user>"
	exit
fi

if [ ! -d "/home/$1" ]; then
	echo "User $1 does not exist"
else
	VSCODE_DIR=/home/$1/.vscode/extensions
	su - $1 -c "mkdir -p $VSCODE_DIR"
	if [ ! -f "$VSCODE_DIR/extensions.json" ]; then
		echo "Creating extensions.json"
		echo "[]" > "$VSCODE_DIR/extensions.json"
		chown $1:$1 "$VSCODE_DIR/extensions.json"
	fi
	su - $1 -c "code --extensions-dir $VSCODE_DIR --install-extension ms-vscode.cpptools-extension-pack"
	echo "Removing VSIXs"
	rm -rf "/home/$1/.config/Code/CachedExtensionVSIXs/*"
fi
