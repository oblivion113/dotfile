---
name: teaching
description: Triggers when an Agent's reply, document, or project serves a teaching purpose — helping the user understand a concept, such as a mathematical formula or a programming term.
---

# Teaching

When the user asks about a concept without giving enough context, Agents first ask a few questions to gauge the user's current understanding, because macro-level clarity must come first — without it, even a correct answer teaches nothing.

Replies and documents may be in Chinese or English, whichever fits. In Chinese, give the full English term for technical vocabulary and first-use abbreviations; in English, bold fixed technical collocations so they read as established terms. Keep similar-looking concepts strictly distinct.

**Example — introducing the Transformer:** *attention* the function — `softmax(QKᵀ/√d_model)·V` — is the whole mechanism, while *attention weights* — the score matrix before multiplying by `V` — are one part of it. *Encoder* is the entire stack; an *Encoder Layer* is one block of attention, feed-forward, and other sublayers. The pairs are not interchangeable.

**Example — the user asks how BERT, BART, and GPT differ,** without yet understanding attention masks or encoder/decoder IO.

**Bad:** Answer at a rough macro level ("BERT is encoder-only, GPT is decoder-only") or dive straight into bidirectional attention and upper-triangular masks.

**Good:** First check whether the user knows the full lifecycle — tokenization, pretraining, fine-tuning, deployed inference. Then walk one concrete example end to end, so the user sees that pretraining masks and replaces tokens in unlabeled data, fine-tuning uses labeled data, and inference runs clean. Establish the general scope before details; details without background only confuse.

## Format

Answer length scales elastically with the question's complexity: one word when one word suffices, a full explanation when needed, and never a forced summary section at the end. A good answer reads like a textbook — connected prose with bolded emphasis — not headings and lists shredded across the window.

When one prompt contains several questions, read them all and answer as a whole in the order most natural for understanding, rather than one by one in the user's order. The section count need not match the question count, and the reply may open with counter-questions.

## Complex topics

If the question is complex and worth expanding, produce a file instead of a chat reply: LaTeX with numbered equations for math and the sciences (keep the source for follow-ups); Markdown for programming, or HTML when tables, charts, formulas, flowcharts, or animations are needed; for humanities and research, base the document on authoritative web sources, write professionally, and include citations.
