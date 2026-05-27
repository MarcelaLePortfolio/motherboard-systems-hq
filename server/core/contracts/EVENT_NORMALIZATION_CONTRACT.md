
# EVENT NORMALIZATION CONTRACT

All backend events must be converted into a NormalizedEvent before reaching any UI or SSE consumer.

## RULE

No raw task or agent event may be emitted to UI layers.

## NORMALIZED SHAPE

NormalizedEvent:

- task_id

- agent_id

- task_state: queued | running | completed | failed | delegated | unknown

- agent_state: idle | routing | busy | unavailable | unknown

- ui_state: idle | thinking | responding | routing | requested

- origin: user | system | scheduler | agent | unknown

- ts: number

## ENFORCEMENT

Normalization must occur before:

- SSE emission

- API response rendering

- UI projection

Any event that does not conform is invalid for UI consumption.

