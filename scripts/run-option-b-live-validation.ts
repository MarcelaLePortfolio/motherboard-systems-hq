import { ollamaChat } from "./utils/ollamaChat";

const expectedOutcome =
  "One reviewable checklist that visibly confirms the Approvals interface is displaying the actual request-specific package contents.";

const message = [
  "Create a non-authoritative package interpretation for this validation request.",
  `Expected outcome: ${expectedOutcome}`,
  "Do not approve, canonicalize, delegate, route, assign, or execute anything.",
].join(" ");

async function main(): Promise<void> {
  console.log("=== LIVE OPTION B INVOCATION ===");
  console.log("VALIDATION_SEED=NONE");
  console.log("OLLAMA_INVOCATION_COUNT=ONE");
  console.log(`TYPED_EXPECTED_OUTCOME=${expectedOutcome}`);

  try {
    const result = await ollamaChat(message, {
      userPackageSemantics: {
        expectedOutcome,
      },
    });

    const actual = result.packageSemantics?.expectedOutcome ?? null;

    console.log("LIVE_RESULT=RETURNED");
    console.log(`AUTHORED_EXPECTED_OUTCOME=${JSON.stringify(actual)}`);
    console.log(
      `EXACT_TYPED_VALUE_PRESERVED=${actual === expectedOutcome ? "YES" : "NO"}`,
    );

    if (actual !== expectedOutcome) {
      throw new Error(
        "Live invocation returned without preserving the exact typed expectedOutcome.",
      );
    }

    console.log("OPTION_B_FIDELITY_BOUNDARY=PASSED");
  } catch (error) {
    const message =
      error instanceof Error ? error.message : String(error);

    console.log("LIVE_RESULT=FAIL_CLOSED");
    console.log(`ERROR=${message}`);

    if (/explicit user package semantics fidelity/i.test(message)) {
      console.log("OPTION_B_FIDELITY_BOUNDARY=REACHED_AND_REJECTED_MISMATCH");
      console.log("LIVE_OPTION_B_VALIDATION=CONCLUSIVE");
      return;
    }

    console.log("OPTION_B_FIDELITY_BOUNDARY=NOT_PROVEN_REACHED");
    console.log("LIVE_OPTION_B_VALIDATION=INCONCLUSIVE");
    process.exitCode = 2;
  }
}

void main();
