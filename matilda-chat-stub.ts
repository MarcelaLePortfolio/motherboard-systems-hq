
/**

 * Matilda chat pipeline stub helper.

 *

 * Current runtime milestone:

 * - Every normal Matilda chat interaction preserves an Interpretation Evidence Ledger entry.

 * - No Draft Package is synthesized here.

 * - No Reconciled Intent Summary is generated here.

 * - No Package is created here.

 * - No Delegation, Validation, Envelope, routing, assignment, or Cade execution is authorized here.

 */


export type MatildaChatInput = {

  message: string;

  agent?: string | null;

  project_id?: string | null;

  conversation_id?: string | null;

};

export type MatildaChatMeta = {

  timestamp: string;

  pipeline: "matilda-stub";

  interpretation_entry_id: string;

};

export type MatildaChatResult = {

  ok: boolean;

  agent: string;

  message: string;

  reasoning: string;

  reply: string;

  meta: MatildaChatMeta;

};

function makeInterpretationEntryId(): string {

  const random = Math.random().toString(36).slice(2, 8);

  return `iel-chat-${Date.now()}-${random}`;

}

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

  const interpretationEntryId = makeInterpretationEntryId();

  const reasoningParts: string[] = [

    `Agent selected: ${agent}`,

    `Message length: ${message.length}`,

    `IEL identity reserved: ${interpretationEntryId}`,

    "Mode: Matilda chat with Interpretation Evidence Ledger persistence",

    "Package created: false",

    "Delegation authorized: false",

    "Execution authorized: false",

  ];

  const replyLines: string[] = [

    "I received your message and preserved it in the Interpretation Evidence Ledger.",

    `IEL Entry: ${interpretationEntryId}`,

    "No Package, Delegation, Envelope, or Cade execution was created from this chat interaction.",

    "The next layer will use these ledger entries to build a living Draft Package and eventually a reviewable Reconciled Intent Summary.",

  ];

  return {

    ok: true,

    agent,

    message,

    reasoning: reasoningParts.join(" | "),

    reply: replyLines.join("\n"),

    meta: {

      timestamp,

      pipeline: "matilda-stub",

      interpretation_entry_id: interpretationEntryId,

    },

  };

}

