# dotfiles

Personal configuration, synced across macOS and WSL through this repository.

Layout: each topic folder is split by platform — `macos/` and `wsl/` hold
platform-specific files, while `skills/general/` holds whatever works
everywhere.

```
neovim/     Neovim configuration (init.lua, nvim-pack-lock.json)
shell/      zsh startup files and tool configuration: common/, macos/, wsl/
skills/     Agent skills for pi (general/ plus platform-specific ones)
sysprompt/  global AGENTS.md: macos/, wsl/
sync/       the sync tool: manifest.toml + sync.py
secret/     local only, git-ignored
```

## Borrowing these configs

This repo is public — feel free to look around and take whatever is
useful. The most reusable pieces are the pi agent skills under
`skills/` (both the platform-agnostic ones in `skills/general/` and the
platform-specific ones) and the AI-harness setup in `sysprompt/`, which
together show how a global AGENTS.md plus on-demand skills can shape an
agent's behavior. The `sync/` tool is similarly general: one
`manifest.toml` mapping repo files to device paths is all it needs.

Anything sensitive (credentials, internal addresses, hostnames) is
excluded from version control. If you adapt these configs, keep that split.

## Shell setup

Both machines run zsh. Startup files are split into:

- `shell/common/` — everything OS-independent, installed at the same device
  path on every machine: `zsh/common.zsh` (fzf, zoxide, Starship, Conda,
  The Fuck, nvim aliases, the shared agent venv, and key sourcing), the fzf
  config at `.config/fzf/fzfrc`, the fzf/`fd` ignore list at
  `.config/search/ignore`, and `.condarc` (base auto-activation off). Each
  platform's `.zshrc` sources the shared fragment, so tool integration is
  written once.
- `shell/macos/` and `shell/wsl/` — platform `.zshrc`/`.zshenv`/`.zprofile`
  and platform-only helpers (Homebrew and the `rtui` shortcut on macOS;
  `winopen`, nvm, and TeX/Cargo PATH setup on WSL).

All shell files are **copy** entries: the live copies under `~` are real
files the shell reads directly, while the repo holds the backup and is not
special at runtime (only skills and `AGENTS.md` are symlinked). After editing
a live file, `push` it; on another machine, `pull` to receive the update.

## Local secrets

`secret/` is a local backup area excluded by `.gitignore` and absent from the
sync manifest. On every machine the live secrets live in `~/.config/secrets/`
(directory mode `0700`, files mode `0600`), with a manual backup under
`secret/<platform>/` in the repo clone:

- **macOS:** `keys.sh` backs up `~/.config/secrets/keys.sh` (currently
  `CONTEXT7_API_KEY`, `ARK_IMAGE_GEN_API_KEY`).
- **WSL:** `secret/wsl/keys.sh` (`ARK_IMAGE_GEN_API_KEY`), plus `windows.sh`
  (Windows host details such as `$WIN`), `sudo-password`, and `tailscale`
  (node IPs for the remote-access skill). Only `keys.sh` is sourced by the
  shared zsh fragment; `windows.sh` is sourced from the WSL `.zshrc`.

Keep values out of tracked files, command output, and documentation. When
changing a secret, update both the live file and the backup and retain mode
`0600`. A non-interactive shell only inherits keys its parent already
exported, so source the live file explicitly in automation and never echo it.

## Syncing

`sync/manifest.toml` maps each repo file to its device location. Entries have
a `mode`: **link** (the device path is a symlink into the repo, edits go live
immediately) or **copy** (two real files, synced explicitly). The device
`target` path is the stable identity of an entry; the repo `source` path is
repaired automatically after restructuring.

```sh
python3 sync/sync.py status    # what is in sync, drifted, or broken
python3 sync/sync.py diff      # device vs repo, for copy entries
python3 sync/sync.py push      # device -> repo   (after tuning a config locally)
python3 sync/sync.py pull      # repo -> device  (on a fresh machine)
python3 sync/sync.py relink    # recreate symlinks (after moving repo files)
python3 sync/sync.py refresh   # repair manifest source paths (after restructuring)
```

Every command accepts entry names to act on a subset (e.g.
`push zshrc nvim-init`), and `-y` to skip confirmations. Nothing runs in the
background; syncing is always an explicit command.

Typical workflows:

- **Tuned a config locally:** edit `~/.zshrc`, then `push zshrc` and commit.
- **Fresh device:** clone, then `pull` (creates symlinks, copies files).
- **Restructured the repo:** `refresh` to fix the manifest, then `relink` to
  fix the now-dangling symlinks on the device.

Adding a new config means adding one `[[entry]]` to `sync/manifest.toml`.

## For Agents

Configuration bodies live in this repository; the device sees them through
`~/.pi/agent/` symlinks (declared in `sync/manifest.toml`). Edit files in the
repo, never through the symlinks' targets. After moving files within the repo,
run `sync.py refresh` and `sync.py relink`, and keep `manifest.toml` in the
same commit as the move.
