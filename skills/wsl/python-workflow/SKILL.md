---
name: python-workflow
description: Triggers whenever Agents use Python — running quick scripts from the terminal, creating or working in Python projects, managing environments and dependencies, choosing between the shared venv, uv, and conda, or deciding whether to use the GPU for model, training, or data workloads.
---

# Python Workflow

## The shared environment for terminal scripts

In a new shell, `python3` resolves to the shared uv-managed virtual environment at `~/.agents/venv` (Python 3.12.14), which is prepended to `PATH` in `~/.bashrc`. This environment is reserved for Agents' everyday terminal work — quick scripts, one-off tasks, and general-purpose experiments. It ships with `pytest`, `pdfplumber`, `numpy`, `pandas`, and `matplotlib`. The venv has no `pip`; add packages with `uv pip install --python ~/.agents/venv/bin/python <pkg>`. The untouched system interpreter (`/usr/bin/python3`, Python 3.14) should never be the target for installs.

## Projects get their own environment

Every real Python project gets its own environment rather than using the shared venv. Agents reach for `uv` first: create the environment in the project root with `uv venv`, producing a `.venv/`, and add dependencies with `uv pip install` or `uv add`. Use conda only when it is genuinely the better tool — typically CUDA-driven or data-science stacks whose native dependencies conda resolves more reliably. Miniconda is installed at `~/miniconda3` with base auto-activation disabled, so it never shadows the shared venv. When conda is used, Agents still create the environment inside the project root (`conda create --prefix ./.venv`) and never install into the base environment.

When a required dependency is missing, Agents install it proactively if it is small and belongs in the environment in question. For a large dependency, Agents stop and explain what is needed, including the install command, before installing. Never install into the system or conda base Python, and do not build low-level workarounds just to avoid a normal dependency.

**Bad:**

```text
pytest is unavailable, so I am replacing it with a custom test runner...
Installing torch and torchvision globally into the system interpreter...
```

## GPU

This machine has an NVIDIA GeForce RTX 5060 Laptop GPU with 8 GB of VRAM, accessible directly from WSL (Windows driver 572.90, CUDA 12.8; `nvidia-smi` works from the shell). GPU acceleration is a real option, so Agents should reach for it rather than assume a CPU-only machine: run model inference, training, and other CUDA-capable workloads on the GPU, and install CUDA-enabled builds when a framework is involved (for example PyTorch with the matching CUDA wheels, or the `pytorch`/`cuda` channels under conda). Treat the 8 GB VRAM as the binding constraint when choosing batch size or model size.
