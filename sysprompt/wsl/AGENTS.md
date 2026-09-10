# AGENTS.md (WSL)

The user is a student learning programming at a beginner level, and wants to learn through interaction with Agents. After completing a task, Agents briefly mention not only *what* was done but also *how*, because this supports learning and follow-up questions.

- Performance has the highest priority: when a trade-off appears, choose performance first; features must not be added or modified at its cost.
- Write elegant, idiomatic code — do not write TypeScript as if it were Python.
- Write documentation and code comments in English unless the user requests another language.
- When an installation fails or is interrupted, Agents clean up the leftovers before retrying or moving on: any half-created install directory and the relevant package-manager cache (for example `uv cache clean` or `npm cache clean --force`), plus any lines the failed installer appended to a shell rc file. A corrupt partial download otherwise poisons the next attempt.
- The user enjoys building enhancements on existing ecosystems — harness plugins, or small tools catering to one or two functions — while expecting formal-software structure: a nice-looking UI, ergonomic interfaces, keyboard shortcuts, proper installation.

## Environment

Ubuntu on WSL2, with Windows interop (`winopen` opens files in their Windows default app). The machine has an NVIDIA RTX 5060 Laptop GPU (8 GB VRAM) reachable from WSL, so prefer the GPU for CUDA-capable Python work; see the `python-workflow` skill. The distribution holds no private data, so `sudo` is fine for genuine privilege escalation; the password is at `~/.config/secrets/sudo-password` (a git-ignored backup lives in `secret/wsl/`).

## Local toolchains

- JavaScript/TypeScript: Node.js v24 via nvm (run `nvm alias default <version>` after installing a node); Bun for zero-setup scripts
- Rust: rustup, cargo, clippy, rustfmt
- C/C++: gcc/g++, Make, CMake
- TeX: TeX Live 2026 in `~/texlive`, managed with `tlmgr`, never apt
- Python: see the `python-workflow` skill — shared agent venv at `~/.agents/venv`, uv for projects, Miniconda at `~/miniconda3` for CUDA stacks
- Documents and media: pandoc, Poppler (`pdftotext`, `pdfinfo`)
- Search and filesystem: ripgrep, fd, fzf, zoxide; Starship prompt; thefuck
