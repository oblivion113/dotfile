---
name: python-workflow
description: Triggers whenever Agents use Python — running scripts, creating or working in Python projects, managing environments and dependencies, or choosing between uv, conda, and the system interpreter.
---

# Python Workflow

The `python3` command in zsh points to `~/.agents/venv/bin/python`, reserved for Agents' default terminal work — quick scripts and one-off tasks. Every real Python project gets its own environment instead.

For projects, use `uv`: create the virtual environment in the project root with `uv venv`, producing `.venv/`. Prefer `uv` over conda whenever it can do the job; when conda is necessary, still create the environment inside the project root and never touch the base environment.

When a required dependency is missing, install it proactively if it is small and belongs in the project environment; for a large dependency, stop and explain what is needed, including the install command. Never install into the base Python environment, and do not build low-level workarounds just to avoid a normal dependency.

**Bad:**

```text
pytest is unavailable, so I am replacing it with a custom test runner...
Installing torch and torchvision globally...
```
