import assert from "node:assert/strict";
import test from "node:test";

type DiagnosticTurn = {
  sourceTurnId: string;
  userMessage: string;
  assistantReply: string;
};

function makeTurns(count: number): DiagnosticTurn[] {
  return Array.from({ length: count }, (_, offset) => {
    const ordinal = String(offset + 1).padStart(3, "0");

    return {
      sourceTurnId: `turn-${ordinal}`,
      userMessage:
        `Synthetic diagnostic user message ${ordinal} ` +
        "with stable semantic-history payload.",
      assistantReply:
        `Synthetic diagnostic Matilda reply ${ordinal} ` +
        "with stable semantic-history payload.",
    };
  });
}

function serializeHistory(turns: readonly DiagnosticTurn[]): string {
  return turns
    .flatMap((turn) => [
      "",
      `Conversation source: ${turn.sourceTurnId}`,
      `User: ${turn.userMessage}`,
      `Matilda: ${turn.assistantReply}`,
    ])
    .join("\n");
}

function serializeSupportIdentities(
  turns: readonly DiagnosticTurn[],
): string {
  const ids = turns.map((turn) => turn.sourceTurnId);

  return [
    "",
    "Allowed conversation support source identifiers:",
    ...(ids.length > 0
      ? ids.map(
          (id) => `Allowed conversation support source = ${id}`,
        )
      : ["Allowed conversation support source = NONE"]),
  ].join("\n");
}

test(
  "measures marginal semantic-history prompt cost without Ollama",
  () => {
    const depths = [0, 20, 25, 50, 75, 100] as const;

    const measurements = depths.map((depth) => {
      const turns = makeTurns(depth);
      const history = serializeHistory(turns);
      const support = serializeSupportIdentities(turns);
      const payload = `${support}\n${history}`;

      return {
        depth,
        characters: payload.length,
        utf8Bytes: Buffer.byteLength(payload, "utf8"),
      };
    });

    for (const measurement of measurements) {
      console.log(
        [
          `DEPTH=${measurement.depth}`,
          `MARGINAL_CHARACTERS=${measurement.characters}`,
          `MARGINAL_UTF8_BYTES=${measurement.utf8Bytes}`,
        ].join(" "),
      );
    }

    for (let index = 1; index < measurements.length; index += 1) {
      assert.ok(
        measurements[index].characters >
          measurements[index - 1].characters,
      );
    }

    console.log("MEASUREMENT_UNIT=CHARACTERS_AND_UTF8_BYTES");
    console.log("TOKEN_COUNT_CLAIM=NO");
    console.log("PRODUCTION_DEPTH_ESTABLISHED=NO");
    console.log("OLLAMA_INVOCATION=NO");
    console.log("MARGINAL_HISTORY_COST_DIAGNOSTIC=PASS");
  },
);
