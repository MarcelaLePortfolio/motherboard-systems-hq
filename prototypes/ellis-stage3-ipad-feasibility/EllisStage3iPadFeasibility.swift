import Foundation
import CryptoKit
import SwiftUI
import UIKit

// ELLIS STAGE 3 — ISOLATED NONPRODUCTION IPAD FEASIBILITY
//
// No production credentials, network transport, issuance,
// persistent signing keys, or Motherboard integration.
//
// Ed25519 private keys are software-held, not Secure Enclave-backed.
// A simulated nonproduction P-256 approval gate is used by the UI.
// No physical iPhone approval or independent authority is established.
// Application confirmation is not independent authority provenance.

enum EllisStage3iPadFeasibilityError: Error {
    case emptyManifest
    case confirmationRequired
    case invalidSignature
}

struct EllisStage3iPadSignatureEvidence {
    let publicKey: Data
    let signature: Data
    let exactBytesVerified: Bool
    let alteredBytesRejected: Bool
}

enum EllisStage3iPadManifestFixture {
    static let fields: [String] = [
        "ELLIS_CREDENTIAL_ISSUANCE_MANIFEST_V1",
        "NONPRODUCTION_ADMINISTRATOR",
        "NONPRODUCTION_AUTHORIZATION",
        "NONPRODUCTION_DEPARTMENT",
        "ISSUE",
        "NONPRODUCTION_CREDENTIAL",
        String(repeating: "0", count: 64),
        "NONPRODUCTION_ISSUANCE",
        "2026-11-06T00:00:00.000Z",
        "2026-11-07T00:00:00.000Z"
    ]

    static func canonicalBytes() throws -> Data {
        try JSONSerialization.data(
            withJSONObject: fields,
            options: []
        )
    }
}

@MainActor
final class EllisStage3iPadFeasibility {
    func signNonproductionManifest(
        _ manifest: Data,
        explicitlyConfirmed: Bool
    ) throws -> EllisStage3iPadSignatureEvidence {
        guard !manifest.isEmpty else {
            throw EllisStage3iPadFeasibilityError.emptyManifest
        }

        guard explicitlyConfirmed else {
            throw EllisStage3iPadFeasibilityError.confirmationRequired
        }

        // Ephemeral nonproduction key.
        // Private-key material is never exported, persisted, or logged.
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKey = privateKey.publicKey
        let signature = try privateKey.signature(for: manifest)

        let exactVerified = publicKey.isValidSignature(
            signature,
            for: manifest
        )

        var alteredManifest = manifest
        alteredManifest.append(0x00)

        let alteredRejected = !publicKey.isValidSignature(
            signature,
            for: alteredManifest
        )

        guard exactVerified && alteredRejected else {
            throw EllisStage3iPadFeasibilityError.invalidSignature
        }

        return EllisStage3iPadSignatureEvidence(
            publicKey: publicKey.rawRepresentation,
            signature: signature,
            exactBytesVerified: exactVerified,
            alteredBytesRejected: alteredRejected
        )
    }
}

struct EllisStage3iPadFeasibilityView: View {
    @State private var reviewedManifest: Data?
    @State private var pendingApproval:
        EllisStage3iPadApprovalFixture.PreparedApproval?
    @State private var reviewPresented = false
    @State private var result = "NOT TESTED"
    @State private var exportedEvidence: String?

    private let feasibility = EllisStage3iPadFeasibility()

    private static func lowercaseHex(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    private static func evidenceBundle(
        manifest: Data,
        evidence: EllisStage3iPadSignatureEvidence
    ) -> String {
        [
            "ELLIS_STAGE3_IPAD_ED25519_NONPRODUCTION_EVIDENCE_V1",
            "manifest_utf8_hex=\(lowercaseHex(manifest))",
            "manifest_sha256_hex=\(lowercaseHex(Data(SHA256.hash(data: manifest))))",
            "public_key_ed25519_hex=\(lowercaseHex(evidence.publicKey))",
            "signature_ed25519_hex=\(lowercaseHex(evidence.signature))",
            "exact_bytes_verified=\(evidence.exactBytesVerified)",
            "altered_bytes_rejected=\(evidence.alteredBytesRejected)",
            "production_issuance=false",
            "independent_iphone_approval_verified=false"
        ].joined(separator: "\n")
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Ellis Stage 3")
                .font(.title)

            Text("iPad Ed25519 Feasibility")
                .font(.headline)

            Text("NONPRODUCTION — NO ISSUANCE")
                .foregroundStyle(.red)

            Text(
                "Review the exact manifest bytes before confirming. " +
                "A simulated nonproduction P-256 approval must verify " +
                "before separate iPad signing confirmation. " +
                "No physical iPhone approval is established."
            )
            .multilineTextAlignment(.center)

            Button("Review Nonproduction Manifest") {
                exportedEvidence = nil

                do {
                    let prepared =
                        try EllisStage3iPadApprovalFixture.prepare()

                    guard EllisStage3iPadApprovalGate.verifyIphoneApproval(
                        manifest: prepared.manifest,
                        evidence: prepared.evidence,
                        trustedKey: prepared.trustedKey
                    ) else {
                        throw EllisStage3iPadApprovalError.invalidEvidence
                    }

                    pendingApproval = prepared
                    reviewedManifest = prepared.manifest
                    reviewPresented = true
                    result = "SIMULATED APPROVAL VERIFIED — AWAITING CONFIRMATION"
                } catch {
                    reviewedManifest = nil
                    pendingApproval = nil
                    result = "APPROVAL VERIFICATION FAILED — NO SIGNING"
                }
            }

            Text(result)
                .font(.system(.body, design: .monospaced))

            if let exportedEvidence {
                Text("NONPRODUCTION PUBLIC VERIFICATION EVIDENCE")
                    .font(.headline)

                ScrollView {
                    Text(exportedEvidence)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 240)

                Button("Copy Nonproduction Evidence") {
                    UIPasteboard.general.string = exportedEvidence
                }
            }
        }
        .padding()
        .sheet(isPresented: $reviewPresented, onDismiss: {
            reviewedManifest = nil
        }) {
            VStack(spacing: 0) {
                Text("Exact Nonproduction Manifest")
                    .font(.headline)
                    .padding()

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let manifest = reviewedManifest,
                           let explanation = EllisStage3iPadManifestExplanation.explanation(
                               for: manifest
                           ) {
                            Text("What You Are Approving")
                                .font(.headline)

                            Text(explanation)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Manifest Fields")
                                .font(.headline)

                            ForEach(0..<10, id: \.self) { index in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(EllisStage3iPadManifestExplanation.labels[index])
                                        .font(.subheadline.bold())

                                    Text(EllisStage3iPadManifestExplanation.expectedFields[index])
                                        .font(.system(.caption, design: .monospaced))
                                        .textSelection(.enabled)
                                }
                            }

                            Text("SHA-256 Fingerprint")
                                .font(.headline)

                            Text(
                                Self.lowercaseHex(Data(SHA256.hash(data: manifest)))
                            )
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)

                            Text("Exact Manifest Bytes (UTF-8)")
                                .font(.headline)

                            Text(
                                String(data: manifest, encoding: .utf8) ?? "INVALID UTF-8"
                            )
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                        } else {
                            Text("Manifest cannot be safely interpreted. Signing is blocked.")
                                .foregroundStyle(.red)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }

                Divider()

                VStack(spacing: 12) {
                    Button("Confirm Signing These Exact Bytes") {
                        performConfirmedTest()
                    }
                    .disabled(
                        reviewedManifest.flatMap {
                            EllisStage3iPadManifestExplanation.explanation(for: $0)
                        } == nil
                    )

                    Button("Cancel", role: .cancel) {
                        reviewedManifest = nil
                        pendingApproval = nil
                        reviewPresented = false
                        exportedEvidence = nil
                        result = "CANCELLED — NO SIGNING"
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
    }

    private func performConfirmedTest() {
        guard let manifest = reviewedManifest,
              let prepared = pendingApproval,
              manifest == prepared.manifest,
              EllisStage3iPadManifestExplanation.explanation(
                  for: manifest
              ) != nil else {
            reviewedManifest = nil
            pendingApproval = nil
            reviewPresented = false
            exportedEvidence = nil
            result = "CONFIRMATION FAILED — NO SIGNING"
            return
        }

        // Consume the reviewed request before attempting signing.
        reviewedManifest = nil
        pendingApproval = nil
        reviewPresented = false
        exportedEvidence = nil

        do {
            // The gate independently revalidates the exact bytes
            // before creating the ephemeral Ed25519 signature.
            let evidence =
                try EllisStage3iPadApprovalGate.signAfterVerification(
                    manifest: manifest,
                    evidence: prepared.evidence,
                    trustedKey: prepared.trustedKey,
                    explicitlyConfirmed: true
                )

            guard evidence.iphoneApprovalVerified,
                  evidence.exactBytesVerified,
                  evidence.productionIssuance == false else {
                result = "VERIFICATION FAILED — NO SIGNING"
                return
            }

            let manifestHex = Self.lowercaseHex(manifest)

            exportedEvidence = [
                "ELLIS_STAGE3_IPAD_DUAL_SIGNATURE_NONPRODUCTION_V1",
                "manifest_utf8_hex=\(manifestHex)",
                "manifest_sha256_hex=\(evidence.manifestSHA256Hex)",
                "iphone_approval_verified=true",
                "iphone_approval_source=SIMULATED_NONPRODUCTION_FIXTURE",
                "iphone_public_key_id=\(prepared.trustedKey.keyID)",
                "iphone_public_key_fingerprint_sha256_hex=\(prepared.trustedKey.fingerprintSHA256Hex)",
                "ipad_public_key_ed25519_hex=\(Self.lowercaseHex(evidence.ipadPublicKeyEd25519))",
                "ipad_signature_ed25519_hex=\(Self.lowercaseHex(evidence.ipadSignatureEd25519))",
                "exact_bytes_verified=true",
                "production_issuance=false",
                "independent_human_authority_established=false"
            ].joined(separator: "\n")

            result = "SIMULATED NONPRODUCTION APPROVAL + IPAD SIGNING PASS"
        } catch {
            result = "VERIFICATION OR SIGNING FAILED"
        }
    }
}
