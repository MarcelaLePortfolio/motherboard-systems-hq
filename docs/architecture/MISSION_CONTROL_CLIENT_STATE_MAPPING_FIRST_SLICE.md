# Mission Control Client State Mapping — First Slice

## Status

Proposed successor corridor to the completed Mission Read API milestone.

## Objective

Create the client-side state layer that consumes the Mission Read API and exposes a presentation-ready Mission Control state without introducing visualization.

## Architectural Flow

MissionDashboardWorkspace
        ↓
useMissionControl()
        ↓
MissionControlProvider
        ↓
Mission Presentation Mapper
        ↓
Mission Read Client
        ↓
GET /api/mission-read/:packageId
        ↓
Mission Read API

## Planned Files

client/src/mission-control/missionReadApi.ts

client/src/mission-control/missionPresentationModel.ts

client/src/mission-control/missionPresentationMapper.ts

client/src/mission-control/MissionControlProvider.tsx

client/src/mission-control/useMissionControl.ts

## Layer Responsibilities

Mission Read Client
• Fetch Mission Read API
• Return typed MissionReadModel
• No React state
• No presentation logic

Mission Presentation Mapper
• Pure deterministic transformation
• Backend truth → Presentation Model
• No fetching
• No React
• No CSS

MissionControlProvider
• Own loading state
• Own ready state
• Own error state
• Own not_found state
• Expose refresh()
• Prevent stale request replacement

MissionDashboardWorkspace
• Consume provider
• No direct fetches
• No API parsing
• No backend interpretation

## Architectural Guardrails

• Backend read models remain authoritative.
• Presentation models remain purely derived.
• Mission Control components never fetch directly.
• Transport state remains separate from mission health.
• Interface state remains separate from organizational state.
• No backend files change during this corridor.

## Validation Gate

✓ Client fetches validated Mission Read endpoint

✓ Loading state

✓ Ready state

✓ Not-found state

✓ Error state

✓ Refresh support

✓ Stale-response protection

✓ Mission Control consumes provider

✓ Client build passes

✓ No backend changes
