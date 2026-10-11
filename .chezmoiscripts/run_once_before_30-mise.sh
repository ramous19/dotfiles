#!/usr/bin/env bash
# Install the mise (https://mise.jdx.dev) binary — nothing else.
#
# Tools are provisioned later by run_once_after_50-mise-tools.sh.
#
# Why the split: `run_once_before_*` scripts execute before chezmoi writes any
# files, so ~/.config/mise/config.toml does not exist yet at this point.
# Calling `mise install` here silently installs nothing on a fresh machine.

set -euo pipefail
log() { printf '\033[0;34m[mise]\033[0m %s\n' "$*"; }

if ! command -v mise >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/mise" ]; then
  log "Installing mise…"
  curl -fsSL https://mise.run | sh
fi

MISE="$(command -v mise || echo "$HOME/.local/bin/mise")"

if [ ! -x "$MISE" ]; then
  printf '\033[0;31m[mise]\033[0m mise install failed — binary not found.\n' >&2
  exit 1
fi

log "mise version: $("$MISE" --version)"
