import Foundation

/// An object representing metadata about the API.
/// Get more info: https://swagger.io/specification/#infoObject
public struct SwaggerInfo: Codable, Equatable {

    // MARK: - Nested Types

    private enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case title
        case version
        case description
        case termsOfServiceURL = "termsOfService"
        case contact
        case license
    }

    // MARK: - Instance Properties

    private var extensionsContainer: SwaggerExtensionsContainer

    // MARK: -

    /// The title of the application.
    public var title: String

    /// The version of the document
    /// which is distinct from the OpenAPI Specification version or the API implementation version.
    public var version: SwaggerVersion

    /// Description of the application.
    /// [CommonMark syntax](http://spec.commonmark.org/) may be used for rich text representation.
    public var description: String?

    /// A URL to the Terms of Service for the API.
    public var termsOfServiceURL: URL?

    /// The contact information for the exposed API.
    public var contact: SwaggerContactInfo?

    /// The license information for the exposed API.
    public var license: SwaggerLicenseInfo?

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
        title: String,
        version: SwaggerVersion,
        description: String? = nil,
        termsOfServiceURL: URL? = nil,
        contact: SwaggerContactInfo? = nil,
        license: SwaggerLicenseInfo? = nil,
        extensions: [String: Any] = [:]
    ) {
        self.extensionsContainer = SwaggerExtensionsContainer(content: extensions)

        self.title = title
        self.version = version
        self.description = description
        self.termsOfServiceURL = termsOfServiceURL
        self.contact = contact
        self.license = license
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(forKey: .title)
        version = try container.decode(forKey: .version)
        description = try container.decodeIfPresent(forKey: .description)
        termsOfServiceURL = try container.decodeIfPresent(forKey: .termsOfServiceURL)
        contact = try container.decodeIfPresent(forKey: .contact)
        license = try container.decodeIfPresent(forKey: .license)

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

        try container.encode(title, forKey: .title)
        try container.encode(version, forKey: .version)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(termsOfServiceURL, forKey: .termsOfServiceURL)
        try container.encodeIfPresent(contact, forKey: .contact)
        try container.encodeIfPresent(license, forKey: .license)

        try extensionsContainer.encode(to: encoder)
    }
}
