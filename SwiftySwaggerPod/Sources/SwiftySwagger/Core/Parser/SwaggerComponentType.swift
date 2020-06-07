import Foundation

public indirect enum SwaggerComponentType<T: Codable> {

    // MARK: - Enumeration Cases

    case reference(SwaggerReference<T>)
    case value(T)
}

// MARK: - Equatable

extension SwaggerComponentType: Equatable where T: Equatable { }
