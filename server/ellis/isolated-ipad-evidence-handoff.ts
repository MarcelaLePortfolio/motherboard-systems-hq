import {
  createHash,
  createPublicKey,
} from "node:crypto";

import {
  isCanonicalIssuanceManifest,
  type IphoneApprovalEvidence,
} from "./isolated-iphone-approval-evidence.js";

import {
  verifyIsolatedDualDeviceManifest,
  type DualDeviceVerificationDependencies,
  type DualDeviceVerificationResult,
  type IpadManifestSignatureEvidence,
} from "./isolated-dual-device-manifest-verifier.js";

// ELLIS STAGE 3 — NONPRODUCTION EVIDENCE HANDOFF
// No device identity, independent authority, credential issuance,
// production key registration, or network transport is established.

const HEADER = "ELLIS_STAGE3_IPAD_DUAL_SIGNATURE_NONPRODUCTION_V1";
const HEX = /^(?:[0-9a-f]{2})+$/;
const DIGEST = /^[0-9a-f]{64}$/;
const KEY_ID = /^[A-Za-z0-9_-]{1,128}$/;

export type IpadHandoffResult = Readonly<{
  verified: boolean;
  classification: "NONPRODUCTION_DUAL_SIGNATURE_VERIFICATION_ONLY";
}>;

const REJECTED: IpadHandoffResult = Object.freeze({
  verified: false,
  classification: "NONPRODUCTION_DUAL_SIGNATURE_VERIFICATION_ONLY",
});

function parseBundle(bundle: string): Record<string, string> | null {
  const lines = bundle.split("\n");

  if (lines.shift() !== HEADER) {
    return null;
  }

  const fields: Record<string, string> = Object.create(null);

  for (const line of lines) {
    const separator = line.indexOf("=");

    if (separator <= 0) {
      return null;
    }

    const key = line.slice(0, separator);
    const value = line.slice(separator + 1);

    if (
      !/^[a-z][a-z0-9_]*$/.test(key) ||
      Object.prototype.hasOwnProperty.call(fields, key)
    ) {
      return null;
    }

    fields[key] = value;
  }

  return fields;
}

export function verifyIsolatedIpadEvidenceHandoff(
  dependencies: DualDeviceVerificationDependencies,
  bundle: string,
  iphoneEvidence: IphoneApprovalEvidence | unknown,
  trustedIpadKeyId: string,
): IpadHandoffResult {
  try {
    if (
      typeof bundle !== "string" ||
      typeof trustedIpadKeyId !== "string" ||
      !KEY_ID.test(trustedIpadKeyId)
    ) {
      return REJECTED;
    }

    const fields = parseBundle(bundle);

    if (!fields) {
      return REJECTED;
    }

    const expected = [
      "manifest_utf8_hex",
      "manifest_sha256_hex",
      "iphone_approval_verified",
      "iphone_approval_source",
      "iphone_public_key_id",
      "iphone_public_key_fingerprint_sha256_hex",
      "ipad_public_key_ed25519_hex",
      "ipad_signature_ed25519_hex",
      "exact_bytes_verified",
      "production_issuance",
      "independent_human_authority_established",
    ];

    if (
      Object.keys(fields).length !== expected.length ||
      !expected.every((key) =>
        Object.prototype.hasOwnProperty.call(fields, key)
      ) ||
      !HEX.test(fields.manifest_utf8_hex) ||
      !DIGEST.test(fields.manifest_sha256_hex) ||
      !/^[0-9a-f]{64}$/.test(fields.ipad_public_key_ed25519_hex) ||
      !/^[0-9a-f]{128}$/.test(fields.ipad_signature_ed25519_hex) ||
      fields.iphone_approval_verified !== "true" ||
      fields.iphone_approval_source !== "SIMULATED_NONPRODUCTION_FIXTURE" ||
      fields.exact_bytes_verified !== "true" ||
      fields.production_issuance !== "false" ||
      fields.independent_human_authority_established !== "false"
    ) {
      return REJECTED;
    }

    // Bind the exported iPhone provenance to the independently
    // supplied evidence before invoking cryptographic verification.
    if (
      iphoneEvidence === null ||
      typeof iphoneEvidence !== "object" ||
      Array.isArray(iphoneEvidence)
    ) return REJECTED;

    const phone = iphoneEvidence as Record<string, unknown>;

    if (
      phone.public_key_id !== fields.iphone_public_key_id ||
      phone.public_key_fingerprint_sha256_hex !==
        fields.iphone_public_key_fingerprint_sha256_hex ||
      phone.manifest_sha256_hex !== fields.manifest_sha256_hex
    ) return REJECTED;

    const manifest = Buffer.from(fields.manifest_utf8_hex, "hex");

    if (
      !isCanonicalIssuanceManifest(manifest) ||
      createHash("sha256").update(manifest).digest("hex") !==
        fields.manifest_sha256_hex
    ) {
      return REJECTED;
    }

    // Trust is obtained exclusively from verifier-controlled dependencies.
    const trustedIpad = dependencies.resolveTrustedIpadTestKey(
      trustedIpadKeyId
    );

    if (!trustedIpad) {
      return REJECTED;
    }

    const publicKey = createPublicKey({
      key: Buffer.from(trustedIpad.public_key_spki_der),
      format: "der",
      type: "spki",
    });

    const exportedRawKey = Buffer.from(
      fields.ipad_public_key_ed25519_hex,
      "hex"
    );

    if (
      publicKey.asymmetricKeyType !== "ed25519" ||
      !publicKey.export({ format: "der", type: "spki" })
        .subarray(-32)
        .equals(exportedRawKey)
    ) {
      return REJECTED;
    }

    const ipadEvidence: IpadManifestSignatureEvidence = {
      signature_ref:
        `ed25519-manifest:${trustedIpadKeyId}:` +
        fields.ipad_signature_ed25519_hex,
      manifest_sha256_hex: fields.manifest_sha256_hex,
      production_issuance: false,
    };

    const result: DualDeviceVerificationResult =
      verifyIsolatedDualDeviceManifest(
        dependencies,
        manifest,
        iphoneEvidence,
        ipadEvidence
      );

    return result.verified
      ? {
          verified: true,
          classification:
            "NONPRODUCTION_DUAL_SIGNATURE_VERIFICATION_ONLY",
        }
      : REJECTED;
  } catch {
    return REJECTED;
  }
}
