---
name: python-workflow
description: Triggers whenever Agents use Python — running scripts, creating or working in Python projects, managing environments and dependencies, choosing between uv, conda, and the system interpreter, or deciding whether to use the GPU.
---

# Python Workflow

`python3` in a new shell points to `~/.agents/venv/bin/python`, a shared uv-managed venv reserved for Agents' quick terminal scripts. Every real project gets its own environment in the project root. Never install project dependencies into the shared venv, the system interpreter, or any conda base environment.

## uv vs conda

Reach for `uv` first: `uv venv` creates `.venv/`, then `uv pip install` or `uv add` for dependencies. Use conda only when it genuinely resolves better — CUDA-driven and data-science stacks with heavy native dependencies. With conda, still keep the environment in the project root (`conda create --prefix ./.venv`) and leave base untouched; base auto-activation is disabled.

When a dependency is missing, install it proactively if it is small and belongs in the project environment; for a large one, stop and explain what is needed, with the install command. Do not build low-level workarounds to avoid a normal dependency.

**Bad:**

```text
pytest is unavailable, so I am replacing it with a custom test runner...
Installing torch and torchvision globally...
```

## GPU

On machines with an NVIDIA GPU reachable from the shell (`nvidia-smi` works), run model inference, training, and other CUDA-capable workloads on the GPU rather than the CPU, and install CUDA-enabled builds (matching PyTorch CUDA wheels, or conda's `cuda` channels). Treat available VRAM as the binding constraint for batch size and model size. On CPU-only machines, ignore this section.
