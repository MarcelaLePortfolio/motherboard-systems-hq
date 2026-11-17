import assert from "node:assert/strict";
import {
  createHash,
  generateKeyPairSync,
  sign,
} from "node:crypto";
import test from "node:test";

import {
  IPHONE_APPROVAL_EVIDENCE_VERSION,
  type IphoneApprovalEvidence,
} from "./isolated-iphone-approval-evidence.js";

import {
  DUAL_DEVICE_VERIFICATION_CLASSIFICATION,
  type DualDeviceVerificationDependencies,
} from "./isolated-dual-device-manifest-verifier.js";

import {
  verifyIsolatedIpadEvidenceHandoff,
} from "./isolated-ipad-evidence-handoff.js";

const manifest = Buffer.from(JSON.stringify([
  "ELLIS_CREDENTIAL_ISSUANCE_MANIFEST_V1",
  "NONPRODUCTION_ADMINISTRATOR",
  "NONPRODUCTION_AUTHORIZATION",
  "NONPRODUCTION_DEPARTMENT",
  "ISSUE",
  "NONPRODUCTION_CREDENTIAL",
  "0".repeat(64),
  "NONPRODUCTION_ISSUANCE",
  "2026-11-06T00:00:00.000Z",
  "2026-11-07T00:00:00.000Z",
]), "utf8");

const hash = (bytes: Uint8Array): string =>
  createHash("sha256").update(bytes).digest("hex");

const iphone = generateKeyPairSync("ec", {
  namedCurve: "prime256v1",
});
const ipad = generateKeyPairSync("ed25519");

const iphonePublic = iphone.publicKey.export({
  format: "der",
  type: "spki",
}) as Buffer;

const ipadPublic = ipad.publicKey.export({
  format: "der",
  type: "spki",
}) as Buffer;

const iphoneKeyId = "NONPRODUCTION_IPHONE";
const ipadKeyId = "NONPRODUCTION_IPAD";

const iphoneEvidence: IphoneApprovalEvidence = {
  version: IPHONE_APPROVAL_EVIDENCE_VERSION,
  manifest_sha256_hex: hash(manifest),
  public_key_id: iphoneKeyId,
  public_key_fingerprint_sha256_hex: hash(iphonePublic),
  signature_p256_der_hex: sign(
    "sha256",
    manifest,
    iphone.privateKey,
  ).toString("hex"),
  production_issuance: false,
};

const dependencies: DualDeviceVerificationDependencies = {
  resolveTrustedIphoneTestKey: (id) =>
    id === iphoneKeyId
      ? {
          key_id: iphoneKeyId,
          public_key_spki_der: iphonePublic,
          fingerprint_sha256_hex: hash(iphonePublic),
        }
      : null,
  resolveTrustedIpadTestKey: (id) =>
    id === ipadKeyId
      ? {
          key_id: ipadKeyId,
          public_key_spki_der: ipadPublic,
          fingerprint_sha256_hex: hash(ipadPublic),
        }
      : null,
};

const header = "ELLIS_STAGE3_IPAD_DUAL_SIGNATURE_NONPRODUCTION_V1";

function bundle(
  overrides: Record<string, string> = {},
): string {
  const fields: Record<string, string> = {
    manifest_utf8_hex: manifest.toString("hex"),
    manifest_sha256_hex: hash(manifest),
    iphone_approval_verified: "true",
    iphone_approval_source: "SIMULATED_NONPRODUCTION_FIXTURE",
    iphone_public_key_id: iphoneKeyId,
    iphone_public_key_fingerprint_sha256_hex: hash(iphonePublic),
    ipad_public_key_ed25519_hex:
      ipadPublic.subarray(-32).toString("hex"),
    ipad_signature_ed25519_hex:
      sign(null, manifest, ipad.privateKey).toString("hex"),
    exact_bytes_verified: "true",
    production_issuance: "false",
    independent_human_authority_established: "false",
    ...overrides,
  };

  return [
    header,
    ...Object.entries(fields).map(([key, value]) =>
      `${key}=${value}`
    ),
  ].join("\n");
}

function check(
  exported: string = bundle(),
  phone: unknown = iphoneEvidence,
  trust: DualDeviceVerificationDependencies = dependencies,
  ipadId: string = ipadKeyId,
): boolean {
  const result = verifyIsolatedIpadEvidenceHandoff(
    trust,
    exported,
    phone,
    ipadId,
  );

  assert.equal(
    result.classification,
    DUAL_DEVICE_VERIFICATION_CLASSIFICATION,
  );

  return result.verified;
}

test("valid simulated nonproduction handoff verifies", () => {
  assert.equal(check(), true);
});

test("mismatched iPhone key ID is rejected", () => {
  assert.equal(check(bundle({
    iphone_public_key_id: "DIFFERENT_IPHONE",
  })), false);
});

test("mismatched iPhone fingerprint is rejected", () => {
  assert.equal(check(bundle({
    iphone_public_key_fingerprint_sha256_hex:
      "0".repeat(64),
  })), false);
});

test("mismatched iPhone evidence is rejected", () => {
  assert.equal(check(bundle(), {
    ...iphoneEvidence,
    public_key_id: "DIFFERENT_IPHONE",
  }), false);
});

test("invalid iPhone signature is rejected", () => {
  assert.equal(check(bundle(), {
    ...iphoneEvidence,
    signature_p256_der_hex: "00",
  }), false);
});

test("missing iPhone evidence is rejected", () => {
  assert.equal(check(bundle(), null), false);
});

test("altered manifest digest is rejected", () => {
  assert.equal(check(bundle({
    manifest_sha256_hex: "0".repeat(64),
  })), false);
});

test("altered iPad signature is rejected", () => {
  assert.equal(check(bundle({
    ipad_signature_ed25519_hex: "0".repeat(128),
  })), false);
});

test("untrusted iPad key is rejected", () => {
  assert.equal(check(bundle(), iphoneEvidence, dependencies,
    "UNKNOWN_IPAD"), false);
});

test("exported iPad key mismatch is rejected", () => {
  assert.equal(check(bundle({
    ipad_public_key_ed25519_hex: "0".repeat(64),
  })), false);
});

test("production issuance claim is rejected", () => {
  assert.equal(check(bundle({
    production_issuance: "true",
  })), false);
});

test("independent authority claim is rejected", () => {
  assert.equal(check(bundle({
    independent_human_authority_established: "true",
  })), false);
});

test("unsupported approval source is rejected", () => {
  assert.equal(check(bundle({
    iphone_approval_source: "PHYSICAL_DEVICE",
  })), false);
});

test("duplicate bundle field is rejected", () => {
  assert.equal(check(
    bundle() + "\nproduction_issuance=false",
  ), false);
});

test("unexpected bundle field is rejected", () => {
  assert.equal(check(
    bundle() + "\ncredential_issued=true",
  ), false);
});

test("incorrect bundle header is rejected", () => {
  assert.equal(check(
    bundle().replace(header, "UNKNOWN_HEADER"),
  ), false);
});

test("missing exact-byte verification is rejected", () => {
  assert.equal(check(bundle({
    exact_bytes_verified: "false",
  })), false);
});

test("throwing trust resolver fails closed", () => {
  assert.equal(check(
    bundle(),
    iphoneEvidence,
    {
      ...dependencies,
      resolveTrustedIpadTestKey: () => {
        throw new Error("Unavailable");
      },
    },
  ), false);
});
