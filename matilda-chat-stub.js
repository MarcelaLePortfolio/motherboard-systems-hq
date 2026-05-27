/**

* Matilda chat pipeline stub helper (runtime JS version).
*
* This is used directly by server.mjs so the dashboard/container can
* call a real Matilda-style pipeline without needing TypeScript at runtime.
  */

/**

* @typedef {Object} MatildaChatInput
* @property {string} message
* @property {string|null|undefined} [agent]
  */

/**

* @typedef {Object} MatildaChatMeta
* @property {string} timestamp
* @property {"matilda-stub"} pipeline
  */

/**

* @typedef {Object} MatildaChatResult
* @property {boolean} ok
* @property {string} agent
* @property {string} message
* @property {string} reasoning
* @property {string} reply
* @property {MatildaChatMeta} meta
  */

/**

* @param {MatildaChatInput} input
* @returns {Promise<MatildaChatResult>}
  */
  export async function runMatildaStub(input) {
  const rawMessage =
  input && typeof input.message === "string" ? input.message : "";
  const message = rawMessage.trim();

if (!message) {
throw new Error("MatildaChatStub: 'message' must be a non-empty string.");
}

const rawAgent = (input && input.agent) || "matilda";
const agent = String(rawAgent).toLowerCase();

const timestamp = new Date().toISOString();

const reasoningParts = [
`Agent selected: ${agent}`,
`Message length: ${message.length}`,
"Mode: Matilda routing stub (no external runtime yet)",
];

const reasoning = reasoningParts.join(" | ");

const replyLines = [
"Matilda routing stub online.",
`I received: “${message}”.`,
"In a full pipeline, this helper would forward your request to the live Matilda runtime,",
"track her internal decision log, and stream the final response back to the UI.",
"For now, I’m confirming that the Matilda chat pipeline helper is wired and callable.",
];

const reply = replyLines.join("\n");

/** @type {MatildaChatMeta} */
const meta = {
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
