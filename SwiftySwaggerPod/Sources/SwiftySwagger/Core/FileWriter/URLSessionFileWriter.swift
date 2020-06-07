//
//  URLSessionFileWriter.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 31.05.2020.
//

import Foundation
import PathKit

struct URLSessionFileWriter: FileWriter {

	func write(sourceCode: String, path: Path) {

	}

	func writeBaseFiles(path: Path) {
		try? FileManager.default.createDirectory(atPath: path.appending("API/Service").string, withIntermediateDirectories: false, attributes: nil)
		try? FileManager.default.createDirectory(atPath: path.appending("API/Encoding").string, withIntermediateDirectories: false, attributes: nil)

		serviceDictionary.forEach { (name, value) in
			DefaultFileWriter.write(sourceCode: value, path: path.appending("API/Service/\(name).swift"))
		}

		encodingDictionary.forEach { (name, value) in
			DefaultFileWriter.write(sourceCode: value, path: path.appending("API/Encoding/\(name).swift"))
		}
	}

	let serviceDictionary = [
		"EndPointType": Service.endPointType,
		"Router": Service.router,
		"HTTPMethods": Service.httpMethods,
		"HTTPTask": Service.httpTask,
	]

	let encodingDictionary = [
		"ParameterEncoding": Encoding.ParameterEncoding,
		"URLParameterEncoding": Encoding.URLParameterEncoding,
		"JSONParameterEncoder": Encoding.JSONParameterEncoder
	]

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


	enum Service  {
		static let endPointType: String = """
		import Foundation
			protocol EndPointType {
				var baseURL: URL { get }
				var path: String { get }
				var httpMethod: HTTPMethod { get }
				var task: HTTPTask { get }
				var headers: HTTPHeaders? { get }
			}
		"""

		static let router = """
			import Foundation

			enum NetworkResponse:String {
				case success
				case authenticationError = "You need to be authenticated first."
				case badRequest = "Bad request"
				case outdated = "The url you requested is outdated."
				case failed = "Network request failed."
				case noData = "Response returned with no data to decode."
				case unableToDecode = "We could not decode the response."
			}

			enum Result<String>{
				case success
				case failure(String)
			}

			public typealias NetworkRouterCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Error?)->()

			protocol NetworkRouter: class {
				associatedtype EndPoint: EndPointType
				func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
				func cancel()
			}

			class Router<EndPoint: EndPointType>: NetworkRouter {
				private var task: URLSessionTask?

				func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
					let session = URLSession.shared
					do {
						let request = try self.buildRequest(from: route)
						task = session.dataTask(with: request, completionHandler: { data, response, error in
							completion(data, response, error)
						})
					}catch {
						completion(nil, nil, error)
					}
					self.task?.resume()
				}

				func cancel() {
					self.task?.cancel()
				}

				fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {

					var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
											 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
											 timeoutInterval: 10.0)

					request.httpMethod = route.httpMethod.rawValue
					do {
						switch route.task {
						case .request:
							request.setValue("application/json", forHTTPHeaderField: "Content-Type")
						case .requestParameters(let bodyParameters,
												let bodyEncoding,
												let urlParameters):

							try self.configureParameters(bodyParameters: bodyParameters,
														 bodyEncoding: bodyEncoding,
														 urlParameters: urlParameters,
														 request: &request)

						case .requestParametersAndHeaders(let bodyParameters,
														  let bodyEncoding,
														  let urlParameters,
														  let additionalHeaders):

							self.addAdditionalHeaders(additionalHeaders, request: &request)
							try self.configureParameters(bodyParameters: bodyParameters,
														 bodyEncoding: bodyEncoding,
														 urlParameters: urlParameters,
														 request: &request)
						}
						return request
					} catch {
						throw error
					}
				}

				fileprivate func configureParameters(bodyParameters: Encodable?,
													 bodyEncoding: ParameterEncoding,
													 urlParameters: Parameters?,
													 request: inout URLRequest) throws {
					do {
						try bodyEncoding.encode(urlRequest: &request,
												bodyParameters: bodyParameters, urlParameters: urlParameters)
					} catch {
						throw error
					}
				}

				fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
					guard let headers = additionalHeaders else { return }
					for (key, value) in headers {
						request.setValue(value, forHTTPHeaderField: key)
					}
				}

			}
		"""

		static let httpMethods = """
	import Foundation

	public enum HTTPMethod : String {
		case get     = "GET"
		case post    = "POST"
		case put     = "PUT"
		case patch   = "PATCH"
		case delete  = "DELETE"
	}

"""

		static let httpTask = """
	import Foundation

	public typealias HTTPHeaders = [String:String]

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

		static let networkLogger = """
	import Foundation

	class NetworkLogger {
		static func log(request: URLRequest) {

			print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
			defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }

			let urlAsString = request.url?.absoluteString ?? ""
			let urlComponents = NSURLComponents(string: urlAsString)

			let method = request.httpMethod != nil ? "\\(request.httpMethod ?? "")" : ""
			let path = "\\(urlComponents?.path ?? "")"
			let query = "\\(urlComponents?.query ?? "")"
			let host = "\\(urlComponents?.host ?? "")"

			var logOutput = \"\"\"
							\\(urlAsString) \n\n
							\\(method) \\(path)?\\(query) HTTP/1.1 \n
							HOST: \\(host)\n
							\"\"\"
			for (key,value) in request.allHTTPHeaderFields ?? [:] {
				logOutput += "\\(key): \\(value) \n"
			}
			if let body = request.httpBody {
				logOutput += \"n \\(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
			}

			print(logOutput)
		}

		static func log(response: URLResponse) {}
	}

"""
	}
}
