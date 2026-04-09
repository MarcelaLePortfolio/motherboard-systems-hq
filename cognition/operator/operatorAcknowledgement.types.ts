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
