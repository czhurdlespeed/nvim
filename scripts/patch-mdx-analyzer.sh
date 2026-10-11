#!/usr/bin/env sh
# Obsolete on mdx-analyzer >=0.6.4; fixes <=0.6.3 vscode-uri import (CLAUDE.md)
set -eu

SHIM="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/packages/mdx-analyzer/node_modules/@mdx-js/language-server/node_modules/vscode-markdown-languageservice/out/util/vscodeUri.js"

if [ ! -f "$SHIM" ]; then
	echo "mdx-analyzer not installed (shim missing): $SHIM" >&2
	echo "Install it first: nvim -c 'MasonInstall mdx-analyzer'" >&2
	exit 1
fi

if grep -q "import \* as uri from 'vscode-uri'" "$SHIM"; then
	echo "already patched: $SHIM"
	exit 0
fi

perl -0pi -e "s/import uri from 'vscode-uri';/import * as uri from 'vscode-uri';/" "$SHIM"

if grep -q "import \* as uri from 'vscode-uri'" "$SHIM"; then
	echo "patched: $SHIM"
else
	echo "patch failed — unexpected shim contents, inspect: $SHIM" >&2
	exit 1
fi
