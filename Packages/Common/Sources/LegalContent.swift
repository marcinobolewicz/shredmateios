import Foundation

/// Factory for legal document content used across the app.
public enum LegalContent {

    public static var termsTitle: String {
        NSLocalizedString("legal.terms_title", bundle: .module, comment: "")
    }

    public static var privacyTitle: String {
        NSLocalizedString("legal.privacy_title", bundle: .module, comment: "")
    }

    public static var termsSections: [LegalDocumentView.Section] {
        (1...6).map { i in
            LegalDocumentView.Section(
                heading: NSLocalizedString("legal.terms_section_\(i)_heading", bundle: .module, comment: ""),
                body: NSLocalizedString("legal.terms_section_\(i)_body", bundle: .module, comment: "")
            )
        }
    }

    public static var privacySections: [LegalDocumentView.Section] {
        (1...5).map { i in
            LegalDocumentView.Section(
                heading: NSLocalizedString("legal.privacy_section_\(i)_heading", bundle: .module, comment: ""),
                body: NSLocalizedString("legal.privacy_section_\(i)_body", bundle: .module, comment: "")
            )
        }
    }
}
