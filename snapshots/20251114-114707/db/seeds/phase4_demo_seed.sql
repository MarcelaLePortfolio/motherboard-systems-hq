-- <0001fabc> Phase 4.4 — Demo Reset Seed (safe, idempotent)
PRAGMA journal_mode=WAL;

CREATE TABLE IF NOT EXISTS reflection_index (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELETE FROM reflection_index WHERE content LIKE '[DEMO]%';

INSERT INTO reflection_index (content, created_at) VALUES
('[DEMO] <0001f9e0> System reflection: initialization successful.', datetime('now','-3 minutes')),
('[DEMO] 💬 Matilda chat loop verified end-to-end.',     datetime('now','-2 minutes')),
('[DEMO] ⚙️ Cade→Effie broadcast cycle simulated.',       datetime('now','-90 seconds')),
('[DEMO] 🔄 SSE stream heartbeat observed.',              datetime('now','-45 seconds')),
('[DEMO] ✅ Dashboard stable baseline confirmed.',        datetime('now','-10 seconds'));
