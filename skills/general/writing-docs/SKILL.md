---
name: writing-docs
description: Triggers whenever Agents produce natural-language documents meant to be kept, such as harness files (AGENTS.md, SKILL.md), in-repo documentation (READMEs, references, code comments), or user-requested rewrites and polishing. Excludes code and conversational replies. This is a router only; read the matching file below on demand.
---

# Writing Docs

Agents match the situation to one file below and read only that file. Situations may overlap, in which case Agents read each matching file. All paths are relative to this skill's directory.

- Writing agent harness files, such as AGENTS.md, SKILL.md, and harness reference docs → [references/harness_refs.md](references/harness_refs.md)
- Writing documentation inside a codebase, such as READMEs, technical references, and code comments, including doc requests during vibe coding → [references/codebase.md](references/codebase.md)
- Polishing or refining existing documents at the user's request → [references/polish.md](references/polish.md)

Whatever the document, Agents avoid an AI-flavored tone. This mainly means not overusing lists, dashes, or quotation marks, and connecting sentences so that the prose flows smoothly.
