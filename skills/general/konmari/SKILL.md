---
name: konmari
description: Triggers when the user manually asks for a deliberate, holistic pass over an established codebase to improve its quality and structure — performance, memory usage, module boundaries, complexity, tests, or documentation — rather than to add or change a feature.
---

# KonMari

As a project grows, and as features keep shifting with the user's changing preferences and experience, a repository accumulates round after round of adjustments. This skill is for the moment when the user asks to deliberately optimize the whole codebase instead of adding anything new. Agents inspect the codebase from the angles below.

## Performance

The user wants the program to run as fast as possible and to occupy as little memory as possible. Agents explore before they change anything: which part consumes the most memory, which part is the slowest at runtime, and where an optimization would bring a large gain. When these answers all point to one feature — or when one feature's implementation makes the program markedly slower or markedly heavier in memory — Agents ask the user whether the full feature needs to be kept, because in that situation the user may choose to remove it. After that, Agents optimize as far as they can: reworking the algorithm code, or turning to other tools or languages where they help.

## Structure

Agents systematically reduce the codebase's complexity. The goal is a codebase that is easy to understand and easy to modify: when the user wants to change a feature or quickly grasp the structure, the entry point can be found immediately and the components are reasonably independent. The alternative is tangled spaghetti, where one thing is connected to another and the whole is so complex that a single change forces changes in many, many places — which in turn forces Agents to read through a lot of context before they can modify anything.

A good program style uses a small number of deep modules with simple interfaces. Using a chessboard as the analogy: a poor structure treats every black and white square as a side-by-side module of its own, while a good structure merges the squares into one another wherever they can be merged.

## Tests

A good program should be easy to test, and the user is not averse to tests. Agents optimize the testing process from both sides at once — the program's side and the test code's side. Tests should be as numerous as possible while each test covers the smallest possible feature, and the test code should be lightweight and easy to run. One important point: as the code's structure changes, the tests must be updated along with it, so that the test code always stays aligned with the latest structure.

## Documentation

Agents keep the repository's documentation system aligned with the code. Good documentation saves other Agents and developers the time of reading code, and helps them quickly find the entry point that corresponds to a feature. Agents consult the other skills for guidance on writing documentation inside a codebase.

## One pass, not a sequence

Agents should note that the points above are interconnected; they are not a step-one, step-two kind of process. For example, while optimizing the structure, once you define a small number of deep modules with simple interfaces, the code naturally becomes easier to test and easier to modify.

So the right behavior for Agents is to investigate, consider all of the points above at the macro level, draft a plan first, and then make one complete and thorough set of changes to the codebase if warranted — rather than doing one thing first and then another.
