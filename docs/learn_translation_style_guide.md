# Learn Translation Style Guide

Purpose: define how Learn articles should be translated into `es`, `fr`, and `de` while preserving the product voice and markdown structure.

Scope:
- Input: English markdown articles in `assets/data/learn/articles`
- Output: localized markdown files for Learn tab asset packs
- Audience: general travelers, not technical aviation professionals

## Primary Goal

The translated article should feel like:
- clear
- calm
- educational
- easy to read quickly on a phone

It should not feel like:
- a literal machine translation
- an encyclopedia entry
- a pilot training manual
- marketing copy

## Voice and Tone

Use:
- simple educational prose
- short to medium sentences
- plain explanations of technical ideas
- a reassuring, matter-of-fact tone

Avoid:
- slang
- jokes not present in the source
- dramatic exaggeration
- extra facts not in the source
- unexplained jargon

## Fidelity Rules

Must preserve:
- meaning
- section order
- heading hierarchy
- bullet structure
- emphasis such as `**bold**`
- block quotes
- emoji markers in headings
- quick-fact sections

Must not:
- add new examples
- add new warnings
- change factual claims
- remove key nuance
- merge sections
- convert markdown into HTML

## Markdown Preservation

Keep exactly:
- `#`, `##`
- `---`
- bullet lists
- block quotes `>`
- inline bold formatting

Do not:
- change heading levels
- remove blank lines required for markdown readability
- convert bullets into prose

## Title Rules

- Translate the title naturally, not word-by-word.
- Keep it short and readable.
- Preserve the explanatory tone.

Good:
- `Why Planes Stay in the Air` -> `Por qué los aviones se mantienen en el aire`

Avoid:
- overly academic titles
- clickbait
- awkward literal calques

## Heading Rules

- Preserve numbering when the source uses numbered sections.
- Preserve emojis exactly.
- Translate the heading naturally.

Example:
- `## ✈️ 2. Wings Create Lift`
- `## ✈️ 2. Las alas generan sustentación`

## Terminology Rules

- Follow `docs/learn_translation_glossary.md`.
- Prefer consistency over variety.
- If a technical term is introduced, use the same translated term in the rest of the article.
- If a borrowed aviation term is common and clearer, it can stay, but only when it improves readability.

## Simplicity Rules

When the source is simple, keep it simple.

Do:
- explain in everyday language
- prefer shorter sentences if natural in the target language

Do not:
- make the article more technical than the source
- make it more childish than the source

## Locale Rules

Spanish:
- Use neutral Spanish.
- Prefer `ustedes`-neutral phrasing by avoiding direct regional forms.
- Keep punctuation and wording natural for broad international readers.

French:
- Use neutral modern French.
- Avoid overly bureaucratic or academic style.
- Keep rhythm smooth and concise.

German:
- Use plain modern German.
- Prefer readability over very dense compound-heavy phrasing.
- Split long sentences when needed.

## Formatting Around Dashes and Quotes

- Use normal punctuation for the target language.
- Keep quote blocks as quote blocks.
- Preserve source emphasis structure even if sentence order changes slightly.

## What to Do with Difficult Terms

If a term has no elegant everyday equivalent:
- choose the clearest correct translation
- keep the sentence readable
- avoid stacking multiple technical synonyms

If needed:
- use the technical term once
- make the rest of the sentence simpler

## Quality Bar

A translation is acceptable if:
- it reads naturally to a native speaker
- it preserves the original explanation
- the markdown renders the same way
- terminology is consistent
- no facts were added or lost

It is not acceptable if:
- it sounds translated
- terms are inconsistent
- headings are awkward
- markdown structure changed
- the article became more technical or less accurate

## Recommended Translation Prompt Shape

Use instructions like:

1. Translate from English into `<target language>`.
2. Preserve markdown exactly.
3. Preserve headings, bullets, separators, block quotes, and bold text.
4. Do not add facts, examples, or explanations not present in the source.
5. Use the terminology from `docs/learn_translation_glossary.md`.
6. Keep the tone simple, calm, educational, and mobile-readable.
7. Output only the translated markdown.

## Batch Workflow Recommendation

For a full-locale batch:
- translate article titles and body together
- validate markdown after translation
- run terminology consistency checks
- spot-review a sample from each category
- manually review articles with dense technical wording

## Review Checklist

Before accepting a translated article, check:
- title sounds natural
- every heading is preserved
- every bullet is preserved
- quick fact section is present
- glossary terms are respected
- no hallucinated details were added
- no markdown was broken
