import { NextRequest, NextResponse } from "next/server";

type ChatRequestBody = {
message?: string;
agent?: string;
};

type MatildaResponse = {
ok: boolean;
agent: string;
message: string;
reasoning: string;
reply: string;
meta: {
timestamp: string;
pipeline: "matilda-stub";
};
};

export async function POST(req: NextRequest) {
let body: ChatRequestBody;

try {
body = (await req.json()) as ChatRequestBody;
} catch {
return NextResponse.json(
{ ok: false, error: "Invalid JSON body." },
{ status: 400 }
);
}

const rawMessage = body?.message;
const message = typeof rawMessage === "string" ? rawMessage.trim() : "";

if (!message) {
return NextResponse.json(
{ ok: false, error: "Missing 'message' in request body." },
{ status: 400 }
);
}

const rawAgent = body?.agent || "matilda";
const agent = String(rawAgent).toLowerCase();

const timestamp = new Date().toISOString();

const reasoningParts: string[] = [
`Agent selected: ${agent}`,
`Message length: ${message.length}`,
"Mode: Matilda routing stub (no external call yet)",
];

const reasoning = reasoningParts.join(" | ");

const reply =
`Matilda routing stub online.\n` +
`I received: “${message}”.\n` +
`In a full pipeline, this endpoint would forward your request to the live Matilda runtime, ` +
`track her internal decision log, and stream the final response back to the UI.\n` +
`For now, I’m confirming that /api/chat is wired correctly and returning a structured payload.`;

const response: MatildaResponse = {
ok: true,
agent,
message,
reasoning,
reply,
meta: {
timestamp,
pipeline: "matilda-stub",
},
};

return NextResponse.json(response);
}
