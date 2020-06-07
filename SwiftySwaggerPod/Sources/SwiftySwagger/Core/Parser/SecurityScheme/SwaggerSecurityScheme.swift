import Foundation

/// An object representing a security schema that can be used by the operations.
/// Supported schemes are HTTP authentication,
/// an API key (either as a header, a cookie parameter or as a query parameter),
/// OAuth2's common flows (implicit, password, application and access code)
/// and OpenID Connect Discovery.
/// Get more info: https://swagger.io/specification/#securitySchemeObject
public struct SwaggerSecurityScheme: Codable, Equatable {

    // MARK: - Nested Types

    private enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case type
        case description

        case apiKeyName = "name"
        case apiKeyLocation = "in"

        case oauthFlows = "flows"

        case httpScheme = "scheme"
        case httpSchemeBearerFormat = "bearerFormat"

        case openIDConnectURL = "openIdConnectUrl"
    }

    private enum CodingValues {

        // MARK: - Type Properties

        static let apiKeyType = "apiKey"
        static let oauth2Type = "oauth2"
        static let httpType = "http"
        static let openIDConnectType = "openIdConnect"

        static let httpBasicScheme = "basic"
        static let httpBearerScheme = "bearer"
    }

    // MARK: - Instance Properties

    private var extensionsContainer: SwaggerExtensionsContainer

    // MARK: -

    /// The type of the security scheme.
    public var type: SwaggerSecuritySchemeType

    /// Explanation about the purpose of the data described by the schema.
    /// [CommonMark syntax](http://spec.commonmark.org/) may be used for rich text representation.
    public var description: String?

    /// The extensions properties.
    /// Keys will be prefixed by "x-" when encoding.
    /// Values can be a primitive, an array or an object. Can have any valid JSON format value.
    public var extensions: [String: Any] {
        get { return extensionsContainer.content }
        set { extensionsContainer.content = newValue }
    }

    // MARK: - Initializers

    /// Creates a new instance with the provided values.
    public init(
        type: SwaggerSecuritySchemeType,
        description: String?,
        extensions: [String: Any] = [:]
    ) {
        self.extensionsContainer = SwaggerExtensionsContainer(content: extensions)

        self.type = type
        self.description = description
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(String.self, forKey: .type) {
        case CodingValues.apiKeyType:
            type = .apiKey(
                name: try container.decode(String.self, forKey: .apiKeyName),
                in: try container.decode(SwaggerSecurityAPIKeyLocation.self, forKey: .apiKeyLocation)
            )

        case CodingValues.oauth2Type:
            type = .oauth2(flows: try container.decode(SwaggerOAuthFlows.self, forKey: .oauthFlows))

        case CodingValues.httpType:
            let rawScheme = try container.decode(String.self, forKey: .httpScheme)
            let scheme: SwaggerSecurityHTTPScheme

            switch rawScheme {
            case CodingValues.httpBasicScheme:
                scheme = .basic

            case CodingValues.httpBearerScheme:
                scheme = .bearer(format: try container.decodeIfPresent(String.self, forKey: .httpSchemeBearerFormat))

            default:
                scheme = .other(rawScheme)
            }

            type = .http(scheme: scheme)

        case CodingValues.openIDConnectType:
            type = .openIDConnect(url: try container.decode(URL.self, forKey: .openIDConnectURL))

        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Invalid type of the security scheme"
            )
        }

        description = try container.decodeIfPresent(String.self, forKey: .description)

        extensionsContainer = try SwaggerExtensionsContainer(from: decoder)
    }

    // MARK: - Instance Methods

    /// Encodes this instance into the given encoder.
    ///
    /// This function throws an error if any values are invalid for the given encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch type {
        case let .apiKey(name: name, in: location):
            try container.encode(CodingValues.apiKeyType, forKey: .type)
            try container.encode(name, forKey: .apiKeyName)
            try container.encode(location, forKey: .apiKeyLocation)

        case let .oauth2(flows: flows):
            try container.encode(CodingValues.oauth2Type, forKey: .type)
            try container.encode(flows, forKey: .oauthFlows)

        case let .http(scheme: scheme):
            try container.encode(CodingValues.httpType, forKey: .type)

            switch scheme {
            case .basic:
                try container.encode(CodingValues.httpBasicScheme, forKey: .httpScheme)

            case let .bearer(format: format):
                try container.encode(CodingValues.httpBearerScheme, forKey: .httpScheme)
                try container.encode(format, forKey: .httpSchemeBearerFormat)

            case let .other(rawScheme):
                try container.encode(rawScheme, forKey: .httpScheme)
            }

        case let .openIDConnect(url: url):
            try container.encode(CodingValues.openIDConnectType, forKey: .type)
            try container.encode(url, forKey: .openIDConnectURL)
        }

        try container.encodeIfPresent(description, forKey: .description)

        try extensionsContainer.encode(to: encoder)
    }
}
