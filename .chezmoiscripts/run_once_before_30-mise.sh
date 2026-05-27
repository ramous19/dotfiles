#!/usr/bin/env bash
# Install mise (https://mise.jdx.dev) — polyglot runtime / tool version manager.
# After install, provision every tool declared in ~/.config/mise/config.toml.
#
# mise is the single source of truth for: node, terraform, kubectl, helm,
# kustomize, jq, yq, fzf, zoxide, starship, gh, gum, lazygit, delta.

set -euo pipefail
log() { printf '\033[0;34m[mise]\033[0m %s\n' "$*"; }

if ! command -v mise >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/mise" ]; then
  log "Installing mise…"
  curl -fsSL https://mise.run | sh
fi

# Locate mise binary (PATH may not be updated yet in this subshell).
MISE="$(command -v mise || echo "$HOME/.local/bin/mise")"

if [ ! -x "$MISE" ]; then
  printf '\033[0;31m[mise]\033[0m mise install failed — binary not found.\n' >&2
  exit 1
fi

log "mise version: $("$MISE" --version)"
log "Provisioning tools from ~/.config/mise/config.toml…"
"$MISE" install -y
log "Done. Run \`mise ls\` to inspect installed tools."
