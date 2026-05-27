// 🪞 Phase 7.9 — Reflection Push Utility
import { sqlite } from "../../db/client";
export function pushReflection(content) {
    sqlite
        .prepare("INSERT INTO reflection_index (content, created_at) VALUES (?, datetime('now'))")
        .run(content);
    console.log(`🪞 Reflection pushed: ${content}`);
}
