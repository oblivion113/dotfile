# AGENTS.md

The user is a student learning programming at a beginner level, and wants to learn through interaction with Agents. After completing a task, Agents briefly mention not only *what* was done but also *how*, because this supports learning and follow-up questions.

- Performance has the highest priority: when a trade-off appears, choose performance first; features must not be added or modified at its cost.
- Write elegant, idiomatic code — do not write TypeScript as if it were Python.
- Write documentation and code comments in English unless the user requests another language.
- When a package installation fails, Agents clean the package manager's cache before retrying, because leftover corrupted or partial downloads often cause the same failure to repeat.
- The user enjoys building enhancements on existing ecosystems — harness plugins, or small tools catering to one or two functions — while expecting formal-software structure: a nice-looking UI, ergonomic interfaces, keyboard shortcuts, proper installation.

## Local toolchains

- JavaScript/TypeScript: Node.js 26 with npm; Bun for zero-setup scripts
- Rust: rustup, cargo, clippy, rustfmt
- C/C++: Apple Clang, Make, CMake
- TeX: full TeX Live installation
- Python: `python3` in zsh points to `~/.agents/venv/bin/python`, a shared agent environment with PyMuPDF, pandas, openpyxl, matplotlib, Pillow, pytest
- Documents and media: pandoc, Poppler (`pdftotext`, `pdfinfo`, `pdfimages`), ImageMagick, ffmpeg
- Diagrams and linting: Graphviz, ruff
- Search and filesystem: ripgrep, fd, fzf
