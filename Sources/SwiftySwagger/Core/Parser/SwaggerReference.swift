import Foundation

public class SwaggerReference<T: Codable>: Codable {

    // MARK: - Instance Properties

    public let uri: String

    internal private(set) weak var component: SwaggerComponent<T>?

    // MARK: - Initializers

    public init(uri: String) {
        self.uri = uri
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        uri = try container.decode(String.self)

        guard !uri.isEmpty else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Reference URI is empty"
            )
        }

        if let registry = decoder.userInfo[.swaggerReferenceRegistry] as? SwaggerReferenceRegistry {
            registry.registerReference(self)
        }
    }

    // MARK: - Instance Methods

    internal func resolve(with component: SwaggerComponent<T>) {
        self.component = component
    }

    // MARK: -

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        guard !uri.isEmpty else {
            let errorContext = EncodingError.Context(
                codingPath: encoder.codingPath,
                debugDescription: "Reference URI is empty"
            )

            throw EncodingError.invalidValue(uri, errorContext)
        }

        try container.encode(uri)
    }
}

// MARK: - Equatable

extension SwaggerReference: Equatable {

    // MARK: - Type Methods

    public static func == (lhs: SwaggerReference<T>, rhs: SwaggerReference<T>) -> Bool {
        return lhs.uri == rhs.uri
    }
}

// MARK: -

extension CodingUserInfoKey {

    // MARK: - Type Properties

    internal static let swaggerReferenceRegistry = CodingUserInfoKey(rawValue: "SwaggerKit.swaggerReferenceRegistry")!
}
