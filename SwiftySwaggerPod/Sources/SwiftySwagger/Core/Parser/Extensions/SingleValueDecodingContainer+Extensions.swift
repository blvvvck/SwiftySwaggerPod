import Foundation

extension SingleValueDecodingContainer {

    // MARK: - Instance Methods

    internal func decode<T: Decodable>(_ type: T.Type = T.self) throws -> T {
        return try decode(type)
    }
}
