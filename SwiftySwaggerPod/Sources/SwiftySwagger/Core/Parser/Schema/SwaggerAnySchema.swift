import Foundation

/// An object representing an any schema type.
/// This schema matches any data type – numbers, strings, objects, and so on.
/// Get more info: https://swagger.io/specification/#schemaObject
public struct SwaggerAnySchema: Codable, Equatable {

    // MARK: - Nested Types

    private enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case exceptionSchema = "not"
    }

    // MARK: - Instance Properties

    /// Exception scheme.
    /// This means that the value of the schema can be of any type other than the one specified in this property.
    public var exceptionSchema: SwaggerComponent<SwaggerSchema>?

    // MARK: - Initializers

    /// Creates a new instance with the provided exception schema.
    public init(exceptionSchema: SwaggerComponent<SwaggerSchema>? = nil) {
        self.exceptionSchema = exceptionSchema
    }
}
