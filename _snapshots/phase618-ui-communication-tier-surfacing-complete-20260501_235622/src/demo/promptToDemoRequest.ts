export type PromptToDemoRequestInput = {
  prompt: string;
  approved?: boolean;
  governanceEvaluated?: boolean;
  authorityOrderingValid?: boolean;
};

export type DemoTaskDefinition = {
  id: string;
  name: string;
};

export type DemoRequest = {
  requestId: string;
  description: string;
  approved: boolean;
  governanceEvaluated: boolean;
  authorityOrderingValid: boolean;
  tasks: DemoTaskDefinition[];
};

function normalizeWhitespace(value: string): string {
  return value.replace(/\s+/g, " ").trim();
}

function titleCase(value: string): string {
  return value
    .split(" ")
    .filter(Boolean)
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join(" ");
}

function sanitizeTaskName(value: string): string {
  const cleaned = normalizeWhitespace(
    value
      .replace(/^and\s+/i, "")
      .replace(/^then\s+/i, "")
      .replace(/[.;]+$/g, "")
  );

  if (!cleaned) {
    return "";
  }

  return titleCase(cleaned);
}

function extractTasksFromPrompt(prompt: string): string[] {
  const normalized = normalizeWhitespace(prompt);
  const includeMatch = normalized.match(
    /include(?:\s+\w+)?\s+tasks?\s*:\s*(.+?)(?:\.\s|$)/i
  );

  const taskBlock = includeMatch?.[1];

  if (!taskBlock) {
    return [];
  }

  return taskBlock
    .split(/,|\band\b/gi)
    .map(sanitizeTaskName)
    .filter(Boolean);
}

function buildFallbackTasks(prompt: string): string[] {
  const lowered = prompt.toLowerCase();

  if (lowered.includes("launch")) {
    return [
      "Prerequisite Verification",
      "Governance Confirmation",
      "Launch Readiness Assessment",
    ];
  }

  if (lowered.includes("deployment")) {
    return [
      "Dependency Verification",
      "Governance Review Confirmation",
      "Execution Readiness Assessment",
    ];
  }

  return [
    "Scope Verification",
    "Governance Review Confirmation",
    "Execution Readiness Assessment",
  ];
}

export function parsePromptToDemoRequest(
/**
 * FL3_INTAKE_NORMALIZATION_BRIDGE
 * Temporary intake-side proof marker for FL-3 bounded translation corridor.
 * No governance, execution, routing, or reporting mutation permitted here.
 */

  input: PromptToDemoRequestInput
): DemoRequest {
  const normalizedPrompt = normalizeWhitespace(input.prompt);
  const extractedTasks = extractTasksFromPrompt(normalizedPrompt);
  const taskNames =
    extractedTasks.length > 0 ? extractedTasks : buildFallbackTasks(normalizedPrompt);

  const tasks: DemoTaskDefinition[] = taskNames.map((name, index) => ({
    id: `task-${index + 1}`,
    name,
  }));

  const requestIdBase = normalizedPrompt
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 40) || "runtime-demo-request";

  return {
    requestId: `${requestIdBase}-${tasks.length}`,
    description: normalizedPrompt,
    approved: input.approved ?? true,
    governanceEvaluated: input.governanceEvaluated ?? true,
    authorityOrderingValid: input.authorityOrderingValid ?? true,
    tasks,
  };
}
