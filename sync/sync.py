#!/usr/bin/env python3
"""Sync this dotfiles repository with the device it runs on.

Reads sync/manifest.toml, whose entries describe two kinds of mappings:

  link — the device path is a symlink into the repo (live, nothing to copy)
  copy — two real files, synced explicitly with push / pull

Commands:
  status            show the state of every entry for the current platform
  diff   [name...]  unified diff of copy entries (device file vs repo file)
  push   [name...]  device -> repo  (copy entries; link entries are verified)
  pull   [name...]  repo -> device  (copy entries; link entries are re-linked)
  relink [name...]  (re)create symlinks for link entries
  refresh           repair stale `source` paths after restructuring the repo

Everything is manual and on demand; nothing runs in the background.
"""

from __future__ import annotations

import argparse
import difflib
import os
import platform
import shutil
import sys
import tomllib
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
MANIFEST_PATH = Path(__file__).resolve().parent / "manifest.toml"

# Never treat these as candidates when refresh searches the repo.
SEARCH_SKIP = {".git", "secret", "__pycache__"}

KEY_ORDER = ("name", "platform", "mode", "source", "target")


# --- manifest ---------------------------------------------------------------

def load_manifest() -> list[dict]:
    with open(MANIFEST_PATH, "rb") as f:
        return tomllib.load(f)["entry"]


def dump_manifest(entries: list[dict]) -> None:
    """Write entries back as TOML. Only called by refresh, and only when a
    source path actually changed; comments in the file are lost, so the
    canonical header is re-emitted here."""
    lines = [
        "# Dotfiles sync manifest. See sync/sync.py's docstring and README.md.",
        "# Fields: name, platform (macos|wsl|all), mode (link|copy),",
        "# source (repo-relative, repaired by `refresh`), target (device path).",
        "",
    ]
    for e in entries:
        lines.append("[[entry]]")
        for key in KEY_ORDER:
            lines.append(f'{key} = "{e[key]}"')
        lines.append("")
    MANIFEST_PATH.write_text("\n".join(lines))


def current_platform() -> str:
    if sys.platform == "darwin":
        return "macos"
    # WSL sets WSL_DISTRO_NAME and puts "microsoft" in the kernel release.
    if os.environ.get("WSL_DISTRO_NAME") or "microsoft" in platform.release().lower():
        return "wsl"
    return sys.platform  # e.g. native linux; only "all" entries apply


def select(entries: list[dict], names: list[str]) -> list[dict]:
    here = current_platform()
    chosen = [e for e in entries if e["platform"] in (here, "all")]
    if names:
        wanted = set(names)
        unknown = wanted - {e["name"] for e in chosen}
        if unknown:
            sys.exit(f"unknown entry for platform {here}: {', '.join(sorted(unknown))}")
        chosen = [e for e in chosen if e["name"] in wanted]
    return chosen


def paths(entry: dict) -> tuple[Path, Path]:
    source = REPO_ROOT / entry["source"]
    target = Path(entry["target"]).expanduser()
    return source, target


# --- entry state ------------------------------------------------------------

def link_state(source: Path, target: Path) -> str:
    if not source.exists():
        return "missing-source"
    if target.is_symlink():
        actual = Path(os.readlink(target))
        return "ok" if actual == source else f"wrong-link -> {actual}"
    if target.exists():
        return "conflict: real file in the way"
    return "no-link"


def copy_state(source: Path, target: Path) -> str:
    if not source.exists():
        return "missing-source"
    if not target.exists():
        return "missing-target"
    if source.is_dir() or target.is_dir():
        return "unsupported: copy mode handles files only"
    return "ok" if source.read_bytes() == target.read_bytes() else "drifted"


def state(entry: dict) -> str:
    source, target = paths(entry)
    if entry["mode"] == "link":
        return link_state(source, target)
    return copy_state(source, target)


# --- actions ----------------------------------------------------------------

def confirm(question: str, assume_yes: bool) -> bool:
    if assume_yes:
        return True
    try:
        return input(f"{question} [y/N] ").strip().lower() in ("y", "yes")
    except EOFError:  # non-interactive stdin (pipe, agent): default to no
        print(f"{question} [y/N] no (non-interactive; pass -y to confirm)")
        return False


def ensure_link(source: Path, target: Path) -> str:
    """Make target a symlink to source. Returns a short result message."""
    if not source.exists():
        return "skipped: source missing in repo"
    if target.is_symlink():
        if Path(os.readlink(target)) == source:
            return "already linked"
        target.unlink()  # stale or wrong symlink: safe to replace
    elif target.exists():
        return "skipped: a real file/dir occupies the target — move it away first"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.symlink_to(source)
    return "linked"


def cmd_status(entries: list[dict], args) -> None:
    width = max(len(e["name"]) for e in entries)
    for e in entries:
        print(f"{e['name']:<{width}}  {e['mode']:<4}  {state(e)}")


def cmd_diff(entries: list[dict], args) -> None:
    for e in entries:
        if e["mode"] != "copy":
            continue
        source, target = paths(e)
        if not source.exists() or not target.exists():
            print(f"== {e['name']}: {copy_state(source, target)}")
            continue
        diff = difflib.unified_diff(
            target.read_text().splitlines(keepends=True),
            source.read_text().splitlines(keepends=True),
            fromfile=f"device:{target}",
            tofile=f"repo:{source}",
        )
        text = "".join(diff)
        print(f"== {e['name']}" + ("\n" + text if text else ": identical"))


def cmd_push(entries: list[dict], args) -> None:
    for e in entries:
        source, target = paths(e)
        if e["mode"] == "link":
            print(f"{e['name']}: link entry, nothing to push ({link_state(source, target)})")
            continue
        st = copy_state(source, target)
        if st == "ok":
            print(f"{e['name']}: already in sync")
            continue
        if st != "drifted":
            print(f"{e['name']}: {st}")
            continue
        if confirm(f"{e['name']}: overwrite repo file with {target}?", args.yes):
            source.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(target, source)
            print(f"{e['name']}: pushed")


def cmd_pull(entries: list[dict], args) -> None:
    for e in entries:
        source, target = paths(e)
        if e["mode"] == "link":
            print(f"{e['name']}: {ensure_link(source, target)}")
            continue
        st = copy_state(source, target)
        if st == "ok":
            print(f"{e['name']}: already in sync")
            continue
        if st == "missing-source":
            print(f"{e['name']}: {st}")
            continue
        if confirm(f"{e['name']}: overwrite {target} with repo file?", args.yes):
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
            print(f"{e['name']}: pulled")


def cmd_relink(entries: list[dict], args) -> None:
    for e in entries:
        if e["mode"] != "link":
            continue
        source, target = paths(e)
        print(f"{e['name']}: {ensure_link(source, target)}")


def cmd_refresh(entries: list[dict], args) -> None:
    """Repair stale source paths by searching the repo for a file/dir with the
    same name. The target path is the stable identity; the repo layout is not."""
    index: dict[str, list[Path]] = {}
    for root, dirs, files in os.walk(REPO_ROOT):
        # Skip symlinked dirs: a symlink's stored path is just a string and
        # says nothing about where the real file lives now.
        dirs[:] = [
            d for d in dirs
            if d not in SEARCH_SKIP and not (Path(root) / d).is_symlink()
        ]
        names = dirs + [f for f in files if not (Path(root) / f).is_symlink()]
        for name in names:
            index.setdefault(name, []).append(Path(root) / name)

    changed = False
    for e in entries:
        source, _ = paths(e)
        if source.exists():
            continue
        candidates = index.get(source.name, [])
        if len(candidates) == 1:
            new = candidates[0].relative_to(REPO_ROOT)
            print(f"{e['name']}: {e['source']} -> {new}")
            e["source"] = str(new)
            changed = True
        elif candidates:
            print(f"{e['name']}: ambiguous, edit the manifest by hand:")
            for c in candidates:
                print(f"    {c.relative_to(REPO_ROOT)}")
        else:
            print(f"{e['name']}: no file named {source.name} found in the repo")
    if changed:
        dump_manifest(entries)
        print("manifest updated")
    else:
        print("manifest unchanged")


COMMANDS = {
    "status": cmd_status,
    "diff": cmd_diff,
    "push": cmd_push,
    "pull": cmd_pull,
    "relink": cmd_relink,
    "refresh": cmd_refresh,
}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("command", choices=COMMANDS)
    parser.add_argument("names", nargs="*", help="limit to these entries")
    parser.add_argument("-y", "--yes", action="store_true", help="skip confirmations")
    args = parser.parse_args()
    entries = select(load_manifest(), args.names)
    COMMANDS[args.command](entries, args)


if __name__ == "__main__":
    main()
