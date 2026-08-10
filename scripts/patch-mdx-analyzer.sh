#!/usr/bin/env sh
# Patch @mdx-js/language-server (mason package "mdx-analyzer", latest 0.6.3) so
# `mdx-language-server` stops crashing on startup under Node 20+ with:
#   SyntaxError: The requested module 'vscode-uri' does not provide an export named 'default'
#
# Cause: its bundled `vscode-markdown-languageservice` ships an ESM shim
# (out/util/vscodeUri.js) that DEFAULT-imports `vscode-uri`, but vscode-uri's
# ESM build only has NAMED exports (URI, Utils) — so the default import throws.
# We rewrite the one offending line to a namespace import, which resolves the
# named exports. The vscode-uri version is irrelevant (3.0.x and 3.1.x both fail
# the default import and both work with the namespace import).
#
# Idempotent — safe to re-run. mason reinstalling mdx-analyzer wipes
# node_modules, so re-run this after any :MasonInstall/reinstall of it (a plain
# :MasonUpdate won't, since 0.6.3 is already the latest). Enabled in lazy/lsp.lua.
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
