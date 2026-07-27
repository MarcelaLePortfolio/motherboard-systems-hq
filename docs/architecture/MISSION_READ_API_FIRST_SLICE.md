Mission Read API - First Slice
------------------------------

Files:
  routes/api-mission-read.ts
  server/index.ts
  docs/architecture/MISSION_READ_API_FIRST_SLICE.md

Route responsibilities:
  • Accept GET /api/mission-read/:packageId
  • Invoke Mission Read Repository
  • Invoke Mission Read Model Assembler
  • Return assembled MissionReadModel as JSON
  • Return HTTP 404 when package is not found

Server responsibility:
  • Mount the Mission Read router in the Express runtime

Persistence authority:
  • Read governance state from db/main.db
  • Do not modify the legacy motherboard.sqlite runtime boundary

Explicit non-goals:
  • No SQL in the route
  • No model construction in the route
  • No UI changes
  • No new persistence
  • No legacy database migration

Runtime validation:
  • Existing package returned HTTP 200
  • Unknown package returned HTTP 404
  • Server started without SQLite or Mission Read runtime errors
