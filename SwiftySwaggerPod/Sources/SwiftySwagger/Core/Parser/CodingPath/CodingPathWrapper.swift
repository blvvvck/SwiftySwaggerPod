import Foundation

internal struct CodingPathWrapper<T: Decodable>: Decodable {

    // MARK: - Instance Properties

    internal let object: T

    // MARK: - Initializers

    internal init(from decoder: Decoder) throws {
        if var codingPath = decoder.userInfo[.codingPath] as? [String], !codingPath.isEmpty {
            var container = try decoder.container(keyedBy: AnyCodingKey.self)

            while codingPath.count > 1 {
                container = try container.nestedContainer(
                    keyedBy: AnyCodingKey.self,
                    forKey: AnyCodingKey(codingPath[0])
                )

                codingPath = Array(codingPath.dropFirst())
            }

            object = try container.decode(T.self, forKey: AnyCodingKey(codingPath[0]))
        } else {
            object = try T(from: decoder)
        }
    }
}

// MARK: -

extension CodingUserInfoKey {

    // MARK: - Type Properties

    internal static let codingPath = CodingUserInfoKey(rawValue: "codingPath")!
}
