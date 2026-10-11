#!/usr/bin/env bash
# Install gh CLI extensions:
#   dlvhdr/gh-dash    — TUI dashboard for PRs/issues/notifications
#   dlvhdr/gh-enhance — terminal UI for PR review (bound to "T" in gh-dash)
#
# gh itself is provisioned by mise (see ~/.config/mise/config.toml).

set -euo pipefail
log() { printf '\033[0;34m[gh-ext]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[gh-ext]\033[0m %s\n' "$*" >&2; }

# mise-installed gh is not on PATH yet in this subshell.
if ! command -v gh >/dev/null 2>&1; then
  MISE="$(command -v mise || echo "$HOME/.local/bin/mise")"
  GH="$([ -x "$MISE" ] && "$MISE" which gh 2>/dev/null || true)"
  [ -x "$GH" ] && export PATH="$(dirname "$GH"):$PATH"
fi

if ! command -v gh >/dev/null 2>&1; then
  warn "gh CLI not found — skipping extensions. Re-run after \`mise install\`."
  exit 0
fi

install_if_missing() {
  local owner_repo="$1"
  if gh extension list 2>/dev/null | grep -q "$owner_repo"; then
    log "$owner_repo already installed."
  else
    log "Installing $owner_repo…"
    gh extension install "$owner_repo" || warn "Failed to install $owner_repo (auth?)"
  fi
}

install_if_missing dlvhdr/gh-dash
install_if_missing dlvhdr/gh-enhance
log "Done."
