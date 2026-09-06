---
name: writing-docs
description: Triggers whenever Agents produce natural-language documents meant to be kept, such as harness files (AGENTS.md, SKILL.md), in-repo documentation (READMEs, references, code comments), or user-requested rewrites and polishing. Excludes code and conversational replies.
---

# Writing Docs

Writing habits with certain traits are generally considered "AI slop", even when a human wrote them. In wording:

- synonym rotation: "the user", "the customer", "the client" cycled for no reason
- hedging: "it is important to note that this may potentially help"
- frozen verbs: "perform an analysis of" instead of "analyze"
- marketing adjectives: seamless, robust, cutting-edge
- run-ons: four ideas stitched into one sentence
- phrasal verbs: spin up, reach out, dive into

In short, these are habits that carry lots of description but little information. What matters is effective information, not rhetoric that contains none.

The same judgment applies to certain formatting habits, even when a human wrote them:

- using Markdown headings and lists to chop the whole document into a long column, instead of connected, natural prose
- reaching for particular punctuation or forms by reflex — em dashes, double quotation marks, capitalization for emphasis
- documents whose parts all resemble one another, especially a summary section at the end appearing over and over

The user does not want Agents to avoid these traits a hundred percent. First, before anything else, Agents must make sure that proper nouns and technical terms are rendered precisely and correctly — especially when several terms in the same document overlap in vocabulary, they must be kept strictly distinct. Agents must not flatten proper-noun distinctions in the name of simplification; that is never acceptable.

Second, the traits above apply only to technical, engineering, and other STEM writing, whose first requirement is that the reader can follow easily, understand with less effort, and encounter no ambiguity. Agents only need to serve that principle, rather than shunning every listed habit so completely that the result reads like a grade-school composition. A touch of description or craft in a few places is preferable, because rhetoric can sometimes reduce the reader's resistance instead of adding to it.

Likewise, when Agents write literary or advertising copy, whose requirements are artistry or appeal, these standards do not hold. Agents judge when to apply them.

On formatting, none of this forbids particular punctuation or heavily formatted text — both are fine. The point is to use punctuation at a suitable frequency.

For particular situations, Agents follow the guidance in the references folder. The situations below can overlap; when they do, Agents read every reference that the actual task touches:

- Writing agent harness files, such as AGENTS.md, SKILL.md, and harness reference docs → [references/harness_refs.md](references/harness_refs.md)
- Writing documentation inside a codebase, such as READMEs, technical references, and code comments, including doc requests during vibe coding → [references/codebase.md](references/codebase.md)
- Polishing or refining existing documents at the user's request → [references/polish.md](references/polish.md)
