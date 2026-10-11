#!/usr/bin/env bash
# Provision every tool declared in ~/.config/mise/config.toml, then install the
# handful of CLIs that have no mise/registry source.
#
# Runs as `after_` so that ~/.config/mise/config.toml has already been written
# by chezmoi. Numbered 50 so it lands before 60-gh-extensions, which needs the
# mise-provided `gh`.
#
# mise is the single source of truth for: node, python, uv, terraform, kubectl,
# helm, kustomize, jq, yq, fzf, zoxide, starship, carapace, gh, gum, lazygit,
# delta, diffnav.

set -euo pipefail
log()  { printf '\033[0;34m[mise-tools]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[mise-tools]\033[0m %s\n' "$*" >&2; }

MISE="$(command -v mise || echo "$HOME/.local/bin/mise")"
if [ ! -x "$MISE" ]; then
  warn "mise not found — skipping. Re-run \`chezmoi apply\` after installing mise."
  exit 0
fi

log "Provisioning tools from ~/.config/mise/config.toml…"
"$MISE" install -y

# ─── thefuck ─────────────────────────────────────────────────────────────────
# Not in the mise registry, and upstream is unmaintained: it imports
# `distutils.spawn`, removed in Python 3.12, so a default `pip`/`uv` install
# crashes on import. Pinning the tool's interpreter to 3.11 is the fix.
if ! command -v thefuck >/dev/null 2>&1; then
  UV="$("$MISE" which uv 2>/dev/null || true)"
  if [ -x "$UV" ]; then
    log "Installing thefuck (pinned to Python 3.11 — distutils was dropped in 3.12)…"
    "$UV" tool install --python 3.11 thefuck || warn "thefuck install failed — skipping."
  else
    warn "uv not available — skipping thefuck."
  fi
fi

log "Done. Run \`mise ls\` to inspect installed tools."
