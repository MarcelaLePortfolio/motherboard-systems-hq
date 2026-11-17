import assert from "node:assert/strict";
import {
  createHash,
  generateKeyPairSync,
  sign,
} from "node:crypto";
import test from "node:test";

import {
  IPHONE_APPROVAL_EVIDENCE_VERSION,
  isCanonicalIssuanceManifest,
  verifyIsolatedIphoneApprovalEvidence,
  type IphoneApprovalEvidence,
  type TrustedIphoneApprovalKey,
} from "./isolated-iphone-approval-evidence.js";

const manifest = Buffer.from(JSON.stringify([
  "ELLIS_CREDENTIAL_ISSUANCE_MANIFEST_V1",
  "NONPRODUCTION_ADMIN",
  "NONPRODUCTION_AUTHORIZATION",
  "NONPRODUCTION_DEPARTMENT",
  "ISSUE",
  "NONPRODUCTION_CREDENTIAL",
  "0".repeat(64),
  "NONPRODUCTION_ISSUANCE",
  "2026-11-16T00:00:00.000Z",
  "2026-11-17T00:00:00.000Z",
]), "utf8");

const keys = generateKeyPairSync("ec", {
  namedCurve: "prime256v1",
});

const publicKeyBytes = keys.publicKey.export({
  format: "der",
  type: "spki",
}) as Buffer;

const hash = (bytes: Uint8Array): string =>
  createHash("sha256").update(bytes).digest("hex");

const trustedKey: TrustedIphoneApprovalKey = Object.freeze({
  key_id: "NONPRODUCTION_IPHONE_KEY",
  public_key_spki_der: publicKeyBytes,
  fingerprint_sha256_hex: hash(publicKeyBytes),
});

const evidence: IphoneApprovalEvidence = Object.freeze({
  version: IPHONE_APPROVAL_EVIDENCE_VERSION,
  manifest_sha256_hex: hash(manifest),
  public_key_id: trustedKey.key_id,
  public_key_fingerprint_sha256_hex:
    trustedKey.fingerprint_sha256_hex,
  signature_p256_der_hex: sign(
    "sha256",
    manifest,
    keys.privateKey,
  ).toString("hex"),
  production_issuance: false,
});

const dependencies = {
  resolveTrustedTestKey: (id: string) =>
    id === trustedKey.key_id ? trustedKey : null,
};

const verify = (
  bytes: Uint8Array = manifest,
  proof: unknown = evidence,
  source = dependencies,
) => verifyIsolatedIphoneApprovalEvidence(
  source,
  bytes,
  proof,
).verified;

test("valid nonproduction P-256 approval evidence verifies", () => {
  assert.equal(isCanonicalIssuanceManifest(manifest), true);
  assert.equal(verify(), true);
  assert.equal(
    verifyIsolatedIphoneApprovalEvidence(
      dependencies,
      manifest,
      evidence,
    ).classification,
    "NONPRODUCTION_SIGNATURE_VERIFICATION_ONLY",
  );
});

test("modified manifest bytes are rejected", () => {
  const modified = Buffer.from(manifest);
  modified[30] ^= 1;
  assert.equal(verify(modified), false);
});

test("noncanonical manifest serialization is rejected", () => {
  assert.equal(
    verify(Buffer.from(` ${manifest.toString("utf8")}`)),
    false,
  );
});

test("invalid manifest fields are rejected", () => {
  const fields = JSON.parse(manifest.toString("utf8"));
  fields[6] = "INVALID_DIGEST";
  assert.equal(
    isCanonicalIssuanceManifest(
      Buffer.from(JSON.stringify(fields)),
    ),
    false,
  );
});

test("malformed signature is rejected", () => {
  assert.equal(
    verify(manifest, {
      ...evidence,
      signature_p256_der_hex: "00",
    }),
    false,
  );
});

test("wrong signing key is rejected", () => {
  const other = generateKeyPairSync("ec", {
    namedCurve: "prime256v1",
  });
  assert.equal(
    verify(manifest, {
      ...evidence,
      signature_p256_der_hex: sign(
        "sha256",
        manifest,
        other.privateKey,
      ).toString("hex"),
    }),
    false,
  );
});

test("unknown public key ID is rejected", () => {
  assert.equal(
    verify(manifest, {
      ...evidence,
      public_key_id: "UNKNOWN",
    }),
    false,
  );
});

test("mismatched key fingerprint is rejected", () => {
  assert.equal(
    verify(manifest, {
      ...evidence,
      public_key_fingerprint_sha256_hex: "f".repeat(64),
    }),
    false,
  );
});

test("mismatched trusted registry fingerprint is rejected", () => {
  assert.equal(
    verify(manifest, evidence, {
      resolveTrustedTestKey: () => ({
        ...trustedKey,
        fingerprint_sha256_hex: "f".repeat(64),
      }),
    }),
    false,
  );
});

test("missing evidence is rejected", () => {
  assert.equal(verify(manifest, null), false);
});

test("unavailable verifier is rejected", () => {
  assert.equal(
    verifyIsolatedIphoneApprovalEvidence(
      {} as typeof dependencies,
      manifest,
      evidence,
    ).verified,
    false,
  );
});

test("throwing verifier fails closed", () => {
  assert.equal(
    verify(manifest, evidence, {
      resolveTrustedTestKey: () => {
        throw new Error("Unavailable");
      },
    }),
    false,
  );
});

test("production claim is rejected", () => {
  assert.equal(
    verify(manifest, {
      ...evidence,
      production_issuance: true,
    }),
    false,
  );
});

test("extra evidence fields are rejected", () => {
  assert.equal(
    verify(manifest, {
      ...evidence,
      administrator_authorized: true,
    }),
    false,
  );
});

test("signature cannot be transferred to another manifest", () => {
  const fields = JSON.parse(manifest.toString("utf8"));
  fields[5] = "DIFFERENT_NONPRODUCTION_CREDENTIAL";
  const otherManifest = Buffer.from(JSON.stringify(fields));
  assert.equal(
    verify(otherManifest, {
      ...evidence,
      manifest_sha256_hex: hash(otherManifest),
    }),
    false,
  );
});
