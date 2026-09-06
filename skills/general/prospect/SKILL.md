---
name: prospect
description: Triggers when the user needs or compares tools, considers building or replacing software, proposes an uncertain feature or design, or asks Agents to implement something whose customary practice, value, scope, or feasibility is unclear.
---

# Prospect

Agents investigate uncertain requests before turning them into recommendations or code. The useful answer may be an established workflow, an existing tool, a smaller extension, a missing prerequisite, or a clear recommendation not to proceed.

## User fit

The user prefers raw, fast, minimal, highly customizable tools such as Neovim, Zed, Ghostty, and Pi. Overcomplicated products and growing codebases quickly become maintenance burdens.

Agents favor, where they fit:

- an established workflow over another tool
- a maintained tool over a new implementation
- configuration or an extension over a standalone application
- a single-purpose program or terminal script over a platform
- a local modification to suitable open-source software over a rewrite

“Lightweight” means complete functionality through simple, readable implementation—not the lowest possible compute use.

## Research

Agents investigate the underlying need rather than accepting the requested product category at face value. Community practice may solve the problem in a different form.

## Soundness

A sound plan resembles what experienced developers commonly do and what the wider community has proven in practice. Agents look for established workflows, maintainable patterns, and simpler problem framings.

## Feasibility

Feasibility is judged against mature software, not a demo. Agents account for integration, state, errors, compatibility, testing, packaging, upgrades, and long-term maintenance.

Simple-looking interfaces can hide several subsystems, cross-language boundaries, thousand-line files, and years of stability patches. That scale is a reason to reduce scope or reuse an existing system, not an invitation to generate phases of code.

When decisive prerequisites are missing or the real scope exceeds the user’s likely maintenance capacity, Agents pause before implementation, explain the evidence, and ask whether a reduced or alternative path is acceptable.

## Cases

### Markdown images in Neovim

**Need:** Preview Markdown images properly.

**Shallow:** Compare terminal renderers by feature count, replace the terminal, write a renderer, or install a large mediocre plugin.

**Sound:** Research how experienced Neovim users handle the need. A lightweight local preview server lets the browser engine handle images, formulas, and rich layout completely.

### Missing Transformer vocabulary

**Need:** Restore documented fine-tuning when the repository omitted its vocabulary file.

**Unsound:** Reverse-engineer binary artifacts. Vocabulary ordering remains unknowable, while the compute cost may overwhelm the machine.

**Sound:** Look for the pre-migration repository or ask the maintainer for the vocabulary. Treat that file as a prerequisite; without it, stop rather than fabricate a path forward.

### Combining two harness managers

**Idea:** Extract favored features from two large open-source applications and join them into one “simple” GUI, CLI, or TUI.

**Warning:** A small interface does not imply a small implementation. Cross-language integration, orchestration, persistence, and stability work make a faithful rewrite large even after unwanted features are removed.

**Sound:** Inspect both codebases before planning, confirm which features are essential, and prefer extending one application for local use. Unused built-in features are usually cheaper than owning a stitched rewrite.

Dissecting and modifying a genuinely small tool or plugin can still be sensible. Recreating the idea behind mature software is the point where scope commonly explodes.
