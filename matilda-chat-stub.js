"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.runMatildaStub = runMatildaStub;
const matilda_interpretation_runtime_1 = require("./db/matilda-interpretation-runtime");
function makeInterpretationEntryId() {
    const random = Math.random().toString(36).slice(2, 8);
    return `iel-chat-${Date.now()}-${random}`;
}
function clampText(value, maxLength = 4000) {
    const text = String(value || "").trim();
    return text.length > maxLength ? `${text.slice(0, maxLength - 1)}…` : text;
}
async function runMatildaStub(input) {
    const rawMessage = typeof input.message === "string" ? input.message : "";
    const message = rawMessage.trim();
    if (!message) {
        throw new Error("MatildaChatStub: 'message' must be a non-empty string.");
    }
    const rawAgent = input.agent || "matilda";
    const agent = String(rawAgent).toLowerCase();
    const timestamp = new Date().toISOString();
    const ielEntry = (0, matilda_interpretation_runtime_1.createInterpretationEvidenceLedgerEntry)({
        entry_id: makeInterpretationEntryId(),
        actor: agent,
        interpretation_event: "Matilda received a chat interaction and preserved upstream interpretation evidence before any Package creation.",
        minimum_sufficient_context: "Matilda chat interaction received through /api/chat during the Conversation Engine IEL integration corridor.",
        supporting_raw_evidence: clampText(message),
        matilda_observation: "This entry preserves conversation evidence only. It is upstream of Draft Package synthesis, Reconciled Intent Summary generation, approval, canonical Package creation, delegation, validation, envelope creation, routing, assignment, and Cade execution.",
        unresolved_questions: "Future corridor must determine how this evidence updates a living Draft Package and when the conversation becomes reconciliation-ready.",
        lineage_references: "MATILDA_NEXT_CORRIDOR_HANDOFF_2026-07-05.md; MATILDA_INTERPRETATION_EVIDENCE_LEDGER_RUNTIME_VALIDATED_2026-07-05.md",
        supersession_status: "current",
    });
    const reasoningParts = [
        `Agent selected: ${agent}`,
        `Message length: ${message.length}`,
        `IEL entry created: ${ielEntry.entry_id}`,
        "Mode: Matilda chat with Interpretation Evidence Ledger persistence",
        "Package created: false",
        "Delegation authorized: false",
        "Execution authorized: false",
    ];
    const replyLines = [
        "I received your message and preserved it in the Interpretation Evidence Ledger.",
        `IEL Entry: ${ielEntry.entry_id}`,
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
            interpretation_entry_id: ielEntry.entry_id,
        },
    };
}
