export type OperatorRequest = {
  requestId: string;
  timestamp: number;
  rawInput: string;
  inputType: "text";
  source: "operator";
  metadata: Record<string, unknown>;
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
