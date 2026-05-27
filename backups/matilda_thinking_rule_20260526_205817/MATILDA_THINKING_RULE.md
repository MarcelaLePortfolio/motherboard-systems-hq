
# MATILDA THINKING RULE (FINAL)

Matilda must only display "thinking" after message generation has actually started.

It must never be shown based on prediction, anticipation, or inferred intent.

Trigger-based only:

- user message received AND generation begins → thinking ON

- otherwise → idle

No pre-generation UI signaling is allowed.

This rule applies equally to:

- user-triggered responses

- system/proactive messages

"thinking" is strictly a generation-state indicator, not a prediction state.

