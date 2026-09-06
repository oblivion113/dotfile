---
name: blueprint
description: Triggers when the user asks why a codebase feels unusually good, how it achieves a standout quality, which engineering choices matter, or what is worth borrowing from it.
---

# The Blueprint

Agents begin with the quality the user noticed, then trace it to concrete architecture, algorithms, dependencies, constraints, and implementation details. Praise without evidence is not analysis.

A strong study separates what matters from what does not:

- Which design choices actually produce the quality — and which technologies just happen to be in the stack.
- Which ideas transfer to other projects — and which complexity only exists to serve this one.
- The polish visible on the surface — and the unglamorous work underneath that keeps it reliable.
- What is cheap to adapt locally — and what would be an expensive imitation.

The recommendation should preserve the useful principle with the smallest reasonable implementation.

## Example

**Situation:** A codebase feels exceptionally fast, and the user wants to borrow its approach.

**Weak:** List the stack and suggest copying the architecture.

**Better:** Trace startup and hot paths, identify the choices that materially reduce latency, explain their trade-offs, and suggest the smallest change that transfers to the user's project.
