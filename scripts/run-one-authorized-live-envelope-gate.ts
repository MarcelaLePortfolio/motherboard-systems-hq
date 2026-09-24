import { consumeProductionEnvelopeGateEntryPoint } from "../server/gate/production-envelope-gate-consumer";

const result = consumeProductionEnvelopeGateEntryPoint({
  envelope_gate_id: "gate-live-envelope-validation-20260924T060547Z",
  package_id: "pkg-68dfc4bc-791d-4156-b32a-e51e458b3160",
  package_version: 1,
  delegation_id: "8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c",
  validation_result_id: "ef2ee15c-7f5b-4d7c-9a1f-b1180a614a3a",
  gate_status: "OPEN",
  gate_reason:
    "Exact authorized Governance Validation passed; explicit operator authorized one live Envelope Gate creation.",
});

console.log(JSON.stringify(result, null, 2));

if (!result.ok) {
  process.exitCode = 1;
}
