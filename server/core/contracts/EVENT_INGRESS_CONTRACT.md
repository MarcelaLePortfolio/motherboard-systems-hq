
# EVENT INGRESS CONTRACT

All events entering the system must pass through a registered ingress wrapper.

## RULE

No subsystem may emit task or agent events without using the ingress registry.

## REQUIREMENTS

All events must:

1. enter through a registered ingress function

2. pass through normalizeTaskEvent

3. emit only NormalizedEvent objects downstream

Unregistered event emission is invalid behavior.

