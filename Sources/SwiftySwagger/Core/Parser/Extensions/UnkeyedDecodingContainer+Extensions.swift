import Foundation

extension UnkeyedDecodingContainer {

    // MARK: - Instance Methods

    internal mutating func decode<T: Decodable>(_ type: T.Type = T.self) throws -> T {
        return try decode(type)
    }

    internal mutating func decodeIfPresent<T: Decodable>(_ type: T.Type = T.self) throws -> T? {
        return try decodeIfPresent(type)
    }
}
