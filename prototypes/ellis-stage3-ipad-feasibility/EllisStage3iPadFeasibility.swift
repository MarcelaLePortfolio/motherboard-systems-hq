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
// Independent iPhone approval verification is NOT implemented.
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
                "No independent iPhone approval is verified."
            )
            .multilineTextAlignment(.center)

            Button("Review Nonproduction Manifest") {
                exportedEvidence = nil

                do {
                    reviewedManifest =
                        try EllisStage3iPadManifestFixture.canonicalBytes()
                    reviewPresented = true
                    result = "AWAITING EXPLICIT CONFIRMATION"
                } catch {
                    reviewedManifest = nil
                    result = "MANIFEST PREPARATION FAILED"
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
              EllisStage3iPadManifestExplanation.explanation(
                  for: manifest
              ) != nil else {
            reviewedManifest = nil
            reviewPresented = false
            exportedEvidence = nil
            result = "CONFIRMATION FAILED — NO SIGNING"
            return
        }

        // Consume the reviewed request before performing signing.
        reviewedManifest = nil
        reviewPresented = false
        exportedEvidence = nil

        do {
            let evidence = try feasibility.signNonproductionManifest(
                manifest,
                explicitlyConfirmed: true
            )

            if evidence.exactBytesVerified &&
                evidence.alteredBytesRejected {
                exportedEvidence = Self.evidenceBundle(
                    manifest: manifest,
                    evidence: evidence
                )
                result = "APPLICATION-REPORTED TEST PASS"
            } else {
                result = "TEST FAILED"
            }
        } catch {
            result = "TEST FAILED"
        }
    }
}
