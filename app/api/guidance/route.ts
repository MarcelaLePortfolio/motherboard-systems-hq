import { NextResponse } from "next/server";
import { getGuidanceEngine } from "@/server/guidance/guidanceEngine";

/**
 * Phase 666 — Guidance Engine Wiring
 * Read-only integration point. No execution mutation allowed.
 */

export async function GET() {
  try {
    const engine = getGuidanceEngine();

    const guidance = await engine.generate({
      mode: "runtime-observability",
      includeHistory: true,
    });

    return NextResponse.json({
      ok: true,
      source: "guidance-engine",
      data: guidance,
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
