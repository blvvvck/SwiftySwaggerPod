import Foundation

public class SwaggerComponent<T: Codable>: Codable {

    // MARK: - Nested Types

    private enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case reference = "$ref"
    }

    // MARK: - Instance Properties

    public let type: SwaggerComponentType<T>

    public var value: T? {
        switch self.type {
        case let .reference(reference):
            return reference.component?.value

        case let .value(value):
            return value
        }
    }

    // MARK: - Initializers

    public init(type: SwaggerComponentType<T>) {
        self.type = type
    }

    public convenience init(value: T) {
        self.init(type: .value(value))
    }

    public convenience init(reference: SwaggerReference<T>) {
        self.init(type: .reference(reference))
    }

    public convenience init(referenceURI: String) {
        self.init(type: .reference(SwaggerReference(uri: referenceURI)))
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let reference = try container.decodeIfPresent(SwaggerReference<T>.self, forKey: .reference) {
            type = .reference(reference)
        } else {
            type = .value(try T(from: decoder))
        }

        if let registry = decoder.userInfo[.swaggerComponentRegistry] as? SwaggerComponentRegistry {
            registry.registerComponent(self, at: decoder.codingPath)
        }
    }

    // MARK: - Instance Methods

    public func encode(to encoder: Encoder) throws {
        switch type {
        case let .reference(reference):
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(reference, forKey: .reference)

        case let .value(value):
            try value.encode(to: encoder)
        }
    }
}

// MARK: - Equatable

extension SwaggerComponent: Equatable where T: Equatable {

    // MARK: - Type Methods

    public static func == (lhs: SwaggerComponent<T>, rhs: SwaggerComponent<T>) -> Bool {
        return lhs.type == rhs.type
    }
}

// MARK: -

extension CodingUserInfoKey {

    // MARK: - Type Properties

    internal static let swaggerComponentRegistry = CodingUserInfoKey(rawValue: "SwaggerKit.swaggerComponentRegistry")!
}
