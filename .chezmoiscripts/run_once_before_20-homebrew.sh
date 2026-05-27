#!/usr/bin/env bash
# Install Homebrew if missing. Kept only for tools without a clean
# distro / mise source (currently: thefuck, diffnav).
#
# To skip Homebrew entirely, comment out the install command in
# `.chezmoiscripts/run_once_before_40-brew-packages.sh.tmpl`.

set -euo pipefail
log() { printf '\033[0;34m[homebrew]\033[0m %s\n' "$*"; }

if command -v brew >/dev/null 2>&1; then
  log "Homebrew already installed."
  exit 0
fi

if [ -x /home/linuxbrew/.linuxbrew/bin/brew ] || [ -x /opt/homebrew/bin/brew ]; then
  log "Homebrew binary present but not on PATH — will be loaded by ~/.bashrc."
  exit 0
fi

log "Installing Homebrew (non-interactive)…"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
log "Done."
