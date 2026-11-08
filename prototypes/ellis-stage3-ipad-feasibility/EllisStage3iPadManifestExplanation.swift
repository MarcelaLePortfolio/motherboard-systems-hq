import Foundation

// ELLIS STAGE 3 — NONPRODUCTION REVIEW HELPER
// No credential issuance or independent approval authority.

enum EllisStage3iPadManifestExplanation {
    static let expectedFields: [String] = [
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

    static let labels: [String] = [
        "Manifest format",
        "Administrator identifier",
        "Authorization identifier",
        "Department identifier",
        "Requested operation",
        "Credential identifier",
        "Referenced evidence digest",
        "Issuance context",
        "Validity begins (UTC)",
        "Validity ends (UTC)"
    ]

    static func explanation(for manifest: Data) -> String? {
        guard let canonical = try? JSONSerialization.data(
            withJSONObject: expectedFields,
            options: []
        ), manifest == canonical else {
            return nil
        }

        return """
        This is a simulated credential-issuance signing test.

        Requested operation: ISSUE.
        Credential: NONPRODUCTION_CREDENTIAL.
        Administrator, authorization, department, and issuance identifiers:
        nonproduction test values.

        Referenced evidence digest: 64 zeros.
        This is a placeholder, not verified evidence.

        Test validity period:
        November 6, 2026 at 00:00 UTC through
        November 7, 2026 at 00:00 UTC.

        Confirming would sign the exact manifest bytes using an
        ephemeral Ed25519 software key.

        No real credential will be issued.
        No independent iPhone approval has been verified.
        No production authority is granted.
        """
    }
}
