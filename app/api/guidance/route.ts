import { NextResponse } from "next/server";
import { getGuidanceEngine } from "@/server/guidance/guidanceEngine";
import { formatGuidanceForDisplay } from "@/server/guidance/formatGuidance";

/**
 * Phase 672 — Demo Hardening Layer (refactored safely)
 */

export async function GET() {
  try {
    const engine = getGuidanceEngine();

    const result = await engine.generate({
      mode: "runtime-observability",
      includeHistory: true,
    });

    const formatted = {
      ...result,
      guidance: result.guidance.map(formatGuidanceForDisplay),
      meta: {
        ...result.meta,
        mode: "demo-hardening-v2",
      },
    };

    return NextResponse.json({
      ok: true,
      source: "guidance-engine",
      data: formatted,
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
