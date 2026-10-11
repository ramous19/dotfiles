# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/) and
[mise](https://mise.jdx.dev/), designed for fast bootstrap of a new dev
machine across **WSL Ubuntu**, **native Ubuntu/Debian**, and **Arch Linux**.
Codespaces- and Dev Container-ready out of the box.

> Inspired by the structure of [rio/dotfiles](https://github.com/rio/dotfiles).

## Quick start

One-liner on a fresh machine:

```bash
curl -fsSL https://raw.githubusercontent.com/ramous19/dotfiles/main/setup | bash
```

Or, manually:

```bash
git clone https://github.com/ramous19/dotfiles ~/.dotfiles
~/.dotfiles/setup
```

This will:

1. Install `curl`, `git`, and any other missing prerequisites.
2. Install [chezmoi](https://www.chezmoi.io/) into `~/.local/bin`.
3. Run `chezmoi init --apply ramous19`, which:
   - Prompts once for your git name, git email, and a couple of toggles.
   - Clones this repo into `~/.local/share/chezmoi`.
   - Writes the dotfiles into `$HOME` (`~/.bashrc`, `~/.vimrc`, `~/.config/...`).
   - Runs every script under [`.chezmoiscripts/`](.chezmoiscripts/) to install
     system packages, [mise](https://mise.jdx.dev) tools, gh extensions, and
     the JetBrainsMono Nerd Font.

After it finishes, restart your shell:

```bash
exec bash -l
```

## Repository structure

```
.
├── .chezmoi.toml.tmpl                 # First-run prompts + OS/distro/WSL detection
├── .chezmoiignore                     # Repo-meta files to NOT install into $HOME
├── .chezmoiscripts/                   # Install hooks (run by `chezmoi apply`)
│   ├── run_once_before_10-system-packages.sh.tmpl   # apt / pacman + AUR
│   ├── run_once_before_30-mise.sh                   # installs the mise binary
│   ├── run_once_after_50-mise-tools.sh              # `mise install` + thefuck
│   ├── run_once_after_60-gh-extensions.sh           # gh-dash, gh-enhance
│   ├── run_onchange_after_70-fonts.sh.tmpl          # JetBrainsMono Nerd Font
│   └── run_once_after_80-git-ssh.sh.tmpl            # interactive git+SSH setup
├── .devcontainer/                     # VS Code Dev Container + Codespaces config
│   ├── Dockerfile
│   └── devcontainer.json
├── dot_bashrc.tmpl                    # → ~/.bashrc        (templated: WSL branch)
├── dot_bash_logout                    # → ~/.bash_logout
├── dot_bash_carapace                  # → ~/.bash_carapace
├── dot_profile                        # → ~/.profile
├── dot_inputrc                        # → ~/.inputrc
├── dot_vimrc                          # → ~/.vimrc
├── dot_config/
│   ├── mise/config.toml               # → ~/.config/mise/config.toml   (cross-distro tools)
│   ├── starship.toml.tmpl             # → ~/.config/starship.toml      (gcloud-ADC opt-in)
│   ├── carapace/.keep                 # placeholder
│   ├── thefuck/settings.py
│   └── gh-dash/config.yml
├── setup                              # Bootstrap script (curl-able)
├── LICENSE                            # MIT
└── README.md
```

### Why the mise step is split in two

chezmoi runs every `run_once_before_*` script **before it writes any files**.
That means `~/.config/mise/config.toml` does not exist yet while the `before`
scripts run. So `30-mise.sh` only installs the mise *binary*, and
`50-mise-tools.sh` (an `after` script) does the actual `mise install` once the
config is on disk. Collapsing these back into one `before` script silently
installs nothing on a fresh machine.

## How tools are installed

The split between layers is deliberate. Edit the right file when adding a tool:

| Layer                                          | What lives here                                                                                       |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| **`dot_config/mise/config.toml`**              | Almost everything user-space: `node`, `python`, `uv`, `terraform`, `kubectl`, `helm`, `kustomize`, `jq`, `yq`, `fzf`, `zoxide`, `starship`, `carapace`, `gh`, `gum`, `lazygit`, `delta`, `diffnav`. Single source of truth across distros. |
| **System package manager** (apt / pacman+AUR) | System daemons & base toolchain: `git`, `curl`, `build-essential`, `fontconfig`, `vim`, `tree`, `tmux`, `bash-completion`, `net-tools`, `dnsutils`, `redis-tools`, `docker`, `google-cloud-cli` (+ GKE auth plugin), and `wslu` on WSL. |
| **`uv tool`**                                  | `thefuck` only — see below.                                                                            |
| **`gh extension`**                             | `dlvhdr/gh-dash`, `dlvhdr/gh-enhance`.                                                                |
| **`run_onchange_*` font script**               | JetBrainsMono Nerd Font from the [ryanoasis/nerd-fonts release](https://github.com/ryanoasis/nerd-fonts/releases). |

Version policy in `mise/config.toml`: infra tools (`terraform`, `kubectl`,
`helm`) are pinned to a `major.minor` line so an unattended major bump can't
break Terraform state compatibility or cause kubectl/helm API skew against live
clusters. Everything else tracks `latest`.

### Why `thefuck` is special

Upstream `thefuck` is unmaintained and imports `distutils.spawn`, which was
removed in Python 3.12. A plain `pip`/`uv`/`pipx` install therefore crashes on
import. `50-mise-tools.sh` installs it with `uv tool install --python 3.11`,
which gives it a private interpreter that still ships `distutils`.

### Migrating off Homebrew

Earlier revisions of this repo used Homebrew for `thefuck`, `diffnav`,
`terraform`, `delta` and `gum`. All of those now come from mise/uv, and
`~/.bashrc` no longer runs `brew shellenv` — `brew shellenv` *prepends* to
`PATH`, which silently shadowed the mise-managed versions.

If you have a leftover Linuxbrew install, remove it:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
sudo rm -rf /home/linuxbrew
```

## Adding a tool

In 99% of cases, just add a line to [`dot_config/mise/config.toml`](dot_config/mise/config.toml):

```toml
[tools]
ripgrep = "latest"
```

Then re-apply:

```bash
chezmoi apply       # copies the updated config into ~/.config/mise/
mise install        # installs the new tool
```

If the tool is a system daemon (docker-style) or needs OS integration (shell
completion engine, etc.), add it to
[`.chezmoiscripts/run_once_before_10-system-packages.sh.tmpl`](.chezmoiscripts/run_once_before_10-system-packages.sh.tmpl)
under the appropriate `{{ if eq .distro "…" }}` branch.

## Highlights

- **Shell**: `bash` with [Starship](https://starship.rs/) prompt (custom
  multi-segment theme with directory / git / gcloud / language segments).
- **Completion**: [carapace](https://carapace.sh/) bridges `zsh` / `fish` /
  `bash` / `inshellisense` completers.
- **Editor**: `vim` with sane defaults (relative numbers, 2-space indent,
  persistent undo, system clipboard, `jk` → Esc).
- **Smart cd**: [`zoxide`](https://github.com/ajeetdsouza/zoxide) bound to `cd`.
- **Fuzzy finder**: `fzf` via `fzf --bash` (Ctrl-R history, Ctrl-T files,
  Alt-C cd). Carapace is sourced afterwards so it still owns tab completion.
- **GitHub UX**: `gh` CLI with `gh-dash` (PR/issue dashboard) and
  `gh-enhance` (PR review TUI bound to `T`).
- **K8s**: `kubectl` + `helm` + `kustomize` (all via mise — no snap needed).
- **Terminal extras**: `thefuck` (command correction → `fuck`),
  `gum` (interactive prompts), `delta` (git diff viewer), `diffnav`
  (git diff TUI), `lazygit`.
- **Python**: `python` + [`uv`](https://docs.astral.sh/uv/) via mise.

## Customization

[`.chezmoi.toml.tmpl`](.chezmoi.toml.tmpl) prompts on first init for:

- `gitName`, `gitEmail` — seeded into `git config --global`.
- `enableGcloudAdc` — when `true`, the starship prompt displays the email
  from `~/.config/gcloud/application_default_credentials.json`.
  **Default: `false`** to avoid leaking service-account emails in
  screenshots / screencasts / pair-programming sessions.

It also auto-detects:

- `isWSL` — via `WSL_DISTRO_NAME` env or `/proc/sys/fs/binfmt_misc/WSLInterop`.
  When true, `~/.bashrc` exports `BROWSER=wslview` so `gcloud auth` etc.
  open in the Windows browser.
- `distro` — `ubuntu` / `debian` / `arch` / `darwin`. Used by the system-
  packages script to pick `apt` vs `pacman+yay` vs Homebrew.

To re-run the prompts:

```bash
chezmoi init        # re-prompts; existing answers can be edited in ~/.config/chezmoi/chezmoi.toml
```

## Day-to-day

```bash
chezmoi edit ~/.bashrc          # edit a managed file (opens source)
chezmoi diff                    # preview pending changes
chezmoi apply                   # apply changes to $HOME
chezmoi update                  # git pull + apply

mise install                    # install/update everything in mise config
mise use -g <tool>@<ver>        # pin a tool globally
mise ls                         # list installed tools

gh dash                         # open GitHub PR/issue dashboard
```

## VS Code Dev Containers

The repo ships a [`.devcontainer/`](.devcontainer/) folder. Open the repo in VS
Code and **Reopen in Container** to get an Ubuntu 22.04 environment with
chezmoi pre-installed; on container create, `chezmoi init --apply` is run
against the workspace folder so any in-flight edits to dotfiles are tested
immediately.

## GitHub Codespaces

The same `.devcontainer/` config makes this repo Codespaces-ready — every
Codespace you launch (from any repo) will have these dotfiles applied if you
[set this repo as your Codespaces dotfiles source](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles).

## License

[MIT](LICENSE). Use at your own risk — they're opinionated and tuned for me.
