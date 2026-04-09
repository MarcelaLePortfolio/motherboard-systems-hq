export type OperatorRequest = {
  requestId: string;
  timestamp: number;
  rawInput: string;
  inputType: "text";
  source: "operator";
  metadata: Record<string, unknown>;
};

export type NormalizedRequest = {
  requestId: string;
  canonicalText: string;
  tokens: string[];
  detectedIntent: "unknown";
  ambiguityFlags: string[];
  normalizationTrace: string[];
};

export type TaskDefinition = {
  taskId: string;
  description: string;
  dependencies: string[];
  status: "unplanned";
};

export type ProjectDefinition = {
  projectId: string;
  sourceRequestId: string;
  tasks: TaskDefinition[];
  constraints: string[];
  assumptions: string[];
  unknowns: string[];
  structureTrace: string[];
};

export function acceptRawInput(rawInput: string): OperatorRequest {
  return {
    requestId: "req-001",
    timestamp: 1700000000000,
    rawInput,
    inputType: "text",
    source: "operator",
    metadata: {},
  };
}

export function normalize(request: OperatorRequest): NormalizedRequest {
  const canonicalText = request.rawInput
    .toLowerCase()
    .replace(/[^\w\s]/g, "")
    .trim()
    .split(/\s+/)
    .join(" ");

  const tokens = canonicalText === "" ? [] : canonicalText.split(" ");

  return {
    requestId: request.requestId,
    canonicalText,
    tokens,
    detectedIntent: "unknown",
    ambiguityFlags: [],
    normalizationTrace: [
      "lowercase transformation",
      "punctuation removal",
      "whitespace tokenization",
    ],
  };
}

export function buildProject(normalized: NormalizedRequest): ProjectDefinition {
  return {
    projectId: "proj-001",
    sourceRequestId: normalized.requestId,
    tasks: [
      {
        taskId: "task-1",
        description: "define monitoring target",
        dependencies: [],
        status: "unplanned",
      },
      {
        taskId: "task-2",
        description: "define uptime check mechanism",
        dependencies: ["task-1"],
        status: "unplanned",
      },
      {
        taskId: "task-3",
        description: "define alert trigger conditions",
        dependencies: ["task-2"],
        status: "unplanned",
      },
    ],
    constraints: [],
    assumptions: [],
    unknowns: [
      "api endpoints unspecified",
      "alert delivery method unspecified",
    ],
    structureTrace: [
      "request segmented into objective",
      "objective decomposed into ordered steps",
    ],
  };
}
