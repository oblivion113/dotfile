# dotfiles

Personal configuration, synced across macOS and WSL through this repository.

Layout: each topic folder is split by platform — `macos/` and `wsl/` hold
platform-specific files, while `skills/general/` holds whatever works
everywhere.

```
neovim/     Neovim configuration (init.lua, nvim-pack-lock.json)
shell/      zsh startup files (.zshrc, .zshenv, .zprofile)
skills/     Agent skills for pi
sysprompt/  global AGENTS.md
sync/       the sync tool: manifest.toml + sync.py
secret/     local only, git-ignored
```

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
