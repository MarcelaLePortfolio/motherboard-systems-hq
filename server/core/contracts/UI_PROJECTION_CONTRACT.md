
# UI PROJECTION CONTRACT

UI components must not interpret backend events directly.

All UI rendering must derive from NormalizedEvent via projection functions.

## CADE PROJECTION RULES

- routing only

- delegation visibility only

- no conversational states

## MATILDA PROJECTION RULES

- idle

- thinking

- responding only

- no routing or delegation visibility

## RULE

UI must never access raw event fields or DB state.

