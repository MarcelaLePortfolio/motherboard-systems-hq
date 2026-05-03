import { NextRequest, NextResponse } from "next/server";
import { runMinimalDemoFromPrompt } from "@/src/demo/minimalDemoRunner";

type DemoRuntimeRequestBody = {
  prompt?: string;
  approved?: boolean;
  governanceEvaluated?: boolean;
  authorityOrderingValid?: boolean;
};

export async function POST(request: NextRequest) {
  try {
    const body = (await request.json()) as DemoRuntimeRequestBody;

    if (!body.prompt || !body.prompt.trim()) {
      return NextResponse.json(
        { error: "Prompt is required." },
        { status: 400 }
      );
    }

    const report = runMinimalDemoFromPrompt({
      prompt: body.prompt,
      approved: body.approved ?? true,
      governanceEvaluated: body.governanceEvaluated ?? true,
      authorityOrderingValid: body.authorityOrderingValid ?? true,
    });

    return NextResponse.json(report, { status: 200 });
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Unknown runtime demo error.";

    return NextResponse.json({ error: message }, { status: 500 });
  }
}
