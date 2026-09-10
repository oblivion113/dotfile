# dotfiles

Personal configuration, synced across macOS and WSL through this repository.

Layout: each topic folder is split by platform — `macos/` and `wsl/` hold
platform-specific files, while `skills/general/` holds whatever works
everywhere.

```
neovim/     Neovim configuration (init.lua, nvim-pack-lock.json)
shell/      shell startup files and tool configuration
skills/     Agent skills for pi
sysprompt/  global AGENTS.md
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

## macOS shell setup

The macOS zsh files initialize tools from their normal startup locations:
Homebrew and Cargo set `PATH`, while fzf, zoxide, Starship, Conda, and The Fuck
install their shell integration in `.zshrc`. The tracked auxiliary files mirror
their paths under the home directory:

- `shell/macos/.config/fzf/fzfrc` controls fzf's layout and display.
- `shell/macos/.config/search/ignore` is the shared ignore list used by the
  fzf `fd` commands.
- `shell/macos/.condarc` disables automatic activation of Conda's base
  environment.

## Local secrets

### MacOS

`secret/` is a local backup area excluded by `.gitignore` and absent from the
sync manifest. On this Mac, `secret/macos/keys.sh` backs up the live
`~/.config/secrets/keys.sh`; both files have mode `0600`, and the live directory
has mode `0700`. The file currently defines `CONTEXT7_API_KEY` and
`ARK_IMAGE_GEN_API_KEY`. Keep values out of tracked files, command output, and
documentation.

Interactive zsh sources the live file near the end of `.zshrc`. A
non-interactive shell inherits keys only when its parent already exported them;
it does not read `.zshrc` itself. For predictable automation, source the live
file in the command before using a key and never echo the value. The repository
backup is manual: when changing a key, update both copies and retain mode
`0600`.

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
