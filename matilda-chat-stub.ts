/**

* Matilda chat pipeline stub helper.
*
* This does lightweight Matilda-style reasoning/formatting and returns
* a structured response object that callers (like /api/chat) can forward
* directly to the UI.
  */

export type MatildaChatInput = {
message: string;
agent?: string | null;
};

export type MatildaChatMeta = {
timestamp: string;
pipeline: "matilda-stub";
};

export type MatildaChatResult = {
ok: boolean;
agent: string;
message: string;
reasoning: string;
reply: string;
meta: MatildaChatMeta;
};

export async function runMatildaStub(
input: MatildaChatInput
): Promise<MatildaChatResult> {
const rawMessage = typeof input.message === "string" ? input.message : "";
const message = rawMessage.trim();

if (!message) {
throw new Error("MatildaChatStub: 'message' must be a non-empty string.");
}

const rawAgent = input.agent || "matilda";
const agent = String(rawAgent).toLowerCase();

const timestamp = new Date().toISOString();

const reasoningParts: string[] = [
`Agent selected: ${agent}`,
`Message length: ${message.length}`,
"Mode: Matilda routing stub (no external runtime yet)",
];

const reasoning = reasoningParts.join(" | ");

const replyLines: string[] = [
"Matilda routing stub online.",
`I received: “${message}”.`,
"In a full pipeline, this helper would forward your request to the live Matilda runtime,",
"track her internal decision log, and stream the final response back to the UI.",
"For now, I’m confirming that the Matilda chat pipeline helper is wired and callable.",
];

const reply = replyLines.join("\n");

const meta: MatildaChatMeta = {
timestamp,
pipeline: "matilda-stub",
};

return {
ok: true,
agent,
message,
reasoning,
reply,
meta,
};
}
