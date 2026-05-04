import { NextResponse } from "next/server";
import { getGuidanceEngine } from "@/server/guidance/guidanceEngine";

/**
 * Phase 672 — Demo Hardening Layer
 * Output normalization for human-readable intelligence surface.
 */

function formatGuidanceForDisplay(item: any) {
  const severityLabel =
    item.type === "critical"
      ? "requires attention"
      : item.type === "warning"
      ? "monitor"
      : "observe";

  const messageMap: Record<string, string> = {
    "Execution subsystem is not verified.": "Execution integrity requires validation.",
    "Retried tasks are present in recent task history.": "Elevated retry activity detected.",
  };

  return {
    type: item.type,
    severity: item.severity,
    subsystem: item.subsystem,
    message: messageMap[item.message] || item.message,
    tone: severityLabel,
    suggested_action: item.suggested_action,
    generated_at: item.generated_at,
  };
}

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
