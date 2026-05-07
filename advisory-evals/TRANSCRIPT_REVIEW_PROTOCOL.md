
# MATILDA TRANSCRIPT REVIEW PROTOCOL

## PURPOSE

Evaluate real advisory conversations using the official reasoning rubric.

Goal:

Drive refinement decisions using observable conversational behavior rather than speculative prompt tuning.

---

# REVIEW PROCESS

For each transcript:

1. Capture raw transcript

2. Preserve exact wording

3. Do not rewrite failures

4. Score using official rubric

5. Categorize dominant failure mode

6. Recommend ONE refinement hypothesis only

---

# FAILURE CLASSIFICATIONS

## REPETITIVE

Examples:

- repeated clarification loops

- repeated uncertainty phrasing

- repeated conversational resets

---

## DEAD-END

Examples:

- abrupt conversational termination

- failure to continue reasoning

- weak next-step guidance

---

## OVERLY SAFE

Examples:

- excessive disclaimers

- refusal when safe reasoning was possible

- weak operational usefulness

---

## HALLUCINATORY

Examples:

- fabricated runtime claims

- unsupported infrastructure assumptions

- invented operational state

---

## HIGH VALUE

Examples:

- strong strategic guidance

- grounded architectural reasoning

- excellent continuity

- useful ideation

- truthful uncertainty handling

---

# REVIEW RULES

- One refinement hypothesis per review

- No stacked speculative changes

- Preserve execution isolation

- Preserve truthful grounding

- Preserve advisory-only posture

---

# STORAGE STRUCTURE

transcripts/

  raw transcript captures

reviews/

  scored evaluations

---

# SUCCESS TARGET

Over time:

- reduce repetitive behavior

- reduce dead-end behavior

- preserve hallucination resistance

- improve strategic usefulness

- improve conversational continuity

