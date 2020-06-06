import Foundation

public enum SwaggerError: Error, CustomStringConvertible {

    // MARK: - Enumeration Cases

    case loadingFailed(Error, documentURL: URL?)
    case wrongEncoding(documentURL: URL?)

    case invalidComponentURI(String, documentURL: URL?)
    case invalidReferenceURI(String, documentURL: URL?)

    case decodingFailed(Error, documentURL: URL?)
    case encodingFailed(Error, documentURL: URL?)

    // MARK: - Instance Properties

    public var documentURL: URL? {
        switch self {
        case let .loadingFailed(_, documentURL: documentURL):
            return documentURL

        case let .wrongEncoding(documentURL: documentURL):
            return documentURL

        case let .invalidComponentURI(_, documentURL: documentURL):
            return documentURL

        case let .invalidReferenceURI(_, documentURL: documentURL):
            return documentURL

        case let .decodingFailed(_, documentURL: documentURL):
            return documentURL

        case let .encodingFailed(_, documentURL: documentURL):
            return documentURL
        }
    }

    public var description: String {
        let document = documentURL.map { "document (\($0.absoluteString))" } ?? "document"

        switch self {
        case let .loadingFailed(error, documentURL: _):
            return "Specification \(document) could not be loaded: \(error)"

        case .wrongEncoding(documentURL: _):
            return "Specification \(document) characters are not properly encoded"

        case let .invalidComponentURI(uri, documentURL: _):
            return "Specification \(document) contains invalid or inapplicable component URI: \(uri)"

        case let .invalidReferenceURI(uri, documentURL: _):
            return "Specification \(document) contains invalid or inapplicable reference URI: \(uri)"

        case let .decodingFailed(error, documentURL: _):
            return "Specification \(document) could not be decoded: \(error)"

        case let .encodingFailed(error, documentURL: _):
            return "Specification \(document) could not be encoded: \(error)"
        }
    }
}
