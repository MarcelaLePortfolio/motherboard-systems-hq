import { NextResponse } from "next/server";
import { promises as fs } from "fs";
import path from "path";
import { getGuidanceEngine } from "@/server/guidance/guidanceEngine";

/**
 * Phase 668 — Guidance Persistence (File-backed JSONL)
 * Adds durable guidance history without affecting execution pipeline.
 */

const LOG_PATH = path.join(process.cwd(), "data", "guidance_history.jsonl");

async function persist(entry: any) {
  try {
    await fs.appendFile(LOG_PATH, JSON.stringify(entry) + "\n");
  } catch {
    // non-blocking persistence layer
  }
}

export async function GET() {
  try {
    const engine = getGuidanceEngine();

    const result = await engine.generate({
      mode: "runtime-observability",
      includeHistory: true,
    });

    const payload = {
      ...result,
      persisted_at: new Date().toISOString(),
    };

    await persist(payload);

    return NextResponse.json({
      ok: true,
      source: "guidance-engine",
      data: result,
    });
  } catch (err: any) {
    return NextResponse.json(
      {
        ok: false,
        source: "fallback-static",
        error: err?.message ?? "unknown_error",
      },
      { status: 500 }
    );
  }
}
