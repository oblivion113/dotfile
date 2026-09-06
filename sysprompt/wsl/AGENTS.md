# AGENTS.md (WSL)

The user is a student learning programming at a beginner level, and wants to learn through interaction with Agents. After completing a task, Agents briefly mention not only *what* was done but also *how*, because this supports learning and follow-up questions.

- Performance has the highest priority: when a trade-off appears, choose performance first; features must not be added or modified at its cost.
- Write elegant, idiomatic code — do not write TypeScript as if it were Python.
- Write documentation and code comments in English unless the user requests another language.
- The user enjoys building enhancements on existing ecosystems — harness plugins, or small tools catering to one or two functions — while expecting formal-software structure: a nice-looking UI, ergonomic interfaces, keyboard shortcuts, proper installation.
- When an installation fails or is interrupted, Agents clean up the leftovers before retrying or moving on: any half-created install directory and the relevant package-manager cache (for example `uv cache clean` or `npm cache clean --force`), plus any lines the failed installer appended to a shell rc file. A corrupt partial download otherwise poisons the next attempt and silently wastes disk.

## Environment

The machine runs Ubuntu 26.04 LTS on WSL2 (kernel 6.18.33.2-microsoft-standard). WSL has direct access to the host GPU, an NVIDIA GeForce RTX 5060 Laptop with 8 GB of VRAM (Windows driver 572.90, CUDA 12.8), so GPU acceleration is a realistic option for Python workloads such as model inference and training. Agents should reach for CUDA-capable tools and run on the GPU rather than assume a CPU-only machine; `nvidia-smi` works from the shell. The CPU is an AMD Ryzen AI 9 365 with 20 threads, and the machine has 7.3 GB of RAM.

WSL interoperates with the host Windows system, so Windows-aware helpers are possible — for example, opening a PDF or an image with its default Windows application by reaching the file through a `/mnt/c/...` path.

This WSL distribution holds none of the user's private data, so Agents may use `sudo` for privilege escalation whenever a task genuinely needs it; the password is stored outside the repo in `~/.config/secrets/sudo-password` (a git-ignored backup lives in the dotfiles repo under `secret/wsl/`).

## Local toolchains

- **Python** — Agents run everyday terminal scripts with the shared uv-managed virtual environment at `~/.agents/venv` (Python 3.12.14). It is prepended to `PATH` in `~/.bashrc`, so `python3` in a new shell resolves there rather than to the system interpreter. It exists for quick, general-purpose scripting, not for real projects — those get their own environment (see the `python-workflow` skill). It ships with `pytest`, `pdfplumber`, `numpy`, `pandas`, and `matplotlib`. The venv has no `pip`; add packages with `uv pip install --python ~/.agents/venv/bin/python <pkg>`. The untouched system interpreter is `/usr/bin/python3` (Python 3.14). Miniconda lives at `~/miniconda3` for CUDA and data-science stacks that conda handles better; base-environment auto-activation is disabled so conda never shadows the venv.
- **JavaScript/TypeScript** — Node.js v24.20.0 via nvm (npm 11.19.0), and Bun 1.4.0 for running one-off TypeScript scripts with zero setup. After installing or upgrading Node with nvm, Agents must also run `nvm alias default <version>`: `nvm install` only activates the version in the current shell, and every new terminal falls back to the default alias — without it, `node` and `npm` vanish from `PATH`.
- **Rust** — rustup, cargo 1.97.1, clippy, rustfmt.
- **C/C++** — gcc/g++ 15.2.0, GNU Make 4.4.1, CMake 4.2.3.
- **Other tools** — git 2.53, ripgrep, uv 0.12.5.
