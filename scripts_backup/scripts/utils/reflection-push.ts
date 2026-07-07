// 🪞 Phase 7.9 — Reflection Push Utility

export function pushReflection(content: string) {
  sqlite
    .prepare("INSERT INTO reflection_index (content, created_at) VALUES (?, datetime('now'))")
    .run(content);
  console.log(`🪞 Reflection pushed: ${content}`);
}
