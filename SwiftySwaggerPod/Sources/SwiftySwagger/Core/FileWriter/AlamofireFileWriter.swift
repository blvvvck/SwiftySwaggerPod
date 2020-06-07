//
//  AlamofireFileWriter.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 04.06.2020.
//

import Foundation
import PathKit

struct AlamofireFileWriter: FileWriter {
	func write(sourceCode: String, path: Path) {

	}

	func writeBaseFiles(path: Path) {
		try? FileManager.default.createDirectory(atPath: path.appending("API/Core").string, withIntermediateDirectories: false, attributes: nil)
		try? FileManager.default.createDirectory(atPath: path.appending("API/Encoding").string, withIntermediateDirectories: false, attributes: nil)

		serviceDictionary.forEach { (name, value) in
			DefaultFileWriter.write(sourceCode: value, path: path.appending("API/Core/\(name).swift"))
		}

		encodingDictionary.forEach { (name, value) in
			DefaultFileWriter.write(sourceCode: value, path: path.appending("API/Encoding/\(name).swift"))
		}
	}

	let serviceDictionary = [
		"HTTPTask": Service.httpTask,
	]

	let encodingDictionary = [
		"ParameterEncoding": Encoding.ParameterEncoding,
		"URLParameterEncoding": Encoding.URLParameterEncoding,
		"JSONParameterEncoder": Encoding.JSONParameterEncoder
	]


	enum Service  {

			static let httpTask = """
		import Alamofire
		import Foundation

		public enum HTTPTask {
			case request

			case requestParameters(bodyParameters: Encodable?,
				bodyEncoding: ParameterEncoding,
				urlParameters: Parameters?)

			case requestParametersAndHeaders(bodyParameters: Encodable?,
				bodyEncoding: ParameterEncoding,
				urlParameters: Parameters?,
				additionHeaders: HTTPHeaders?)

			// case download, upload...etc
		}
	"""
	}

	enum Encoding  {
			static let ParameterEncoding = """
		import Foundation

		public typealias Parameters = [String:Any]

		public protocol ParameterEncoder {
			func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
		}

		public protocol BodyEncoder {
			func encode(urlRequest: inout URLRequest, with parameters: Encodable) throws
		}

		public enum ParameterEncoding {

			case urlEncoding
			case jsonEncoding
			case urlAndJsonEncoding

			public func encode(urlRequest: inout URLRequest,
							   bodyParameters: Encodable?,
							   urlParameters: Parameters?) throws {
				do {
					switch self {
					case .urlEncoding:
						guard let urlParameters = urlParameters else { return }
						try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)

					case .jsonEncoding:
						guard let bodyParameters = bodyParameters else { return }
						try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)

					case .urlAndJsonEncoding:
						guard let bodyParameters = bodyParameters,
							let urlParameters = urlParameters else { return }
						try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
						try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)

					}
				}catch {
					throw error
				}
			}
		}


		public enum NetworkError : String, Error {
			case parametersNil = "Parameters were nil."
			case encodingFailed = "Parameter encoding failed."
			case missingURL = "URL is nil."
		}
	"""
			static let URLParameterEncoding = """
		import Foundation

		public struct URLParameterEncoder: ParameterEncoder {
			public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {

				guard let url = urlRequest.url else { throw NetworkError.missingURL }

				if var urlComponents = URLComponents(url: url,
													 resolvingAgainstBaseURL: false), !parameters.isEmpty {

					urlComponents.queryItems = [URLQueryItem]()

					for (key,value) in parameters {
						let queryItem = URLQueryItem(name: key,
													 value: "\\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
						urlComponents.queryItems?.append(queryItem)
					}
					urlRequest.url = urlComponents.url
				}

				if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
					urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
				}

			}
		}
	"""

			static let JSONParameterEncoder = """
	import Foundation

		public struct JSONParameterEncoder: BodyEncoder {
			public func encode(urlRequest: inout URLRequest, with parameters: Encodable) throws {
				do {
					urlRequest.httpBody = parameters.toJSONData()
					if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
						urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
					}
				}catch {
					throw NetworkError.encodingFailed
				}
			}
		}

		extension Encodable {
			func toJSONData() -> Data? { try? JSONEncoder().encode(self) }
		}


	"""
		}


}
