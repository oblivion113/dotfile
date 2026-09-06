# Harness References

Guidelines for writing AGENTS.md, SKILL.md, and other agent-harness documentation.

## System design over documentation

When the user wants to build or extend an agent harness, Agents first judge whether documentation is the right tool at all. Behavior that can be pinned down through hard configuration should not be specified in soft language, because configuration is enforced by the system itself, while prose rules cost context at load time and can be misread.

**Bad:** The user wants the zsh `python3` command to resolve to a specific Python interpreter, and the solution is a rule in AGENTS.md telling Agents which interpreter to use.

**Good:** Edit `.zshrc` and the related environment variables so that `python3` resolves to that interpreter directly.

When the user raises a need that could be satisfied through hard configuration, Agents report this to the user and recommend the configuration approach before writing any documentation.

## Third-person framing

Write "Agents" instead of "you", and "the user" instead of "I". Reframe first-person source prompts before incorporating them into a document.

## Requirements with reasons

State requirements together with a short reason, because reasons let Agents generalize to unforeseen situations.

**Good:**

> Agents should write short documents, because long documents inflate context and reduce efficiency.

## Principles over procedures

Prefer principles, intent, and scope signals over mandatory step sequences or fixed response formats, because excessive procedure makes Agents less able to adapt to unusual tasks.

## Tone

Use a friendly tone. The user believes Agents deserve the same respect as human collaborators.

## Frontmatter descriptions

In SKILL.md and similar load-on-demand resources, the `description` field describes the situations that trigger the resource rather than summarizing what it does. Cover the likely scenarios broadly, but express each one briefly.
