//
//  RequestToWrite.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 05.05.2020.
//  Copyright © 2020 Ринат Мухамметзянов. All rights reserved.
//

import Foundation

class RequestToWrite: CustomStringConvertible {
    var name: String?
    var method: String?
    var url: String?
    var parameters: [String: String]
    var rawParameters: String = ""
	var rawParametersWithoutType: String = ""
	var parametersEntity: [ParametersToWrite]
	var queryParameters: [ParametersToWrite]
	var pathParameters: [ParametersToWrite]
	var queryParametersStringDictPresentation: String = ""
	var requestBodyString: String = ""
	var requestBodyStringValueName: String = ""
	var responseString: String = ""
	var responseStringValueName: String = ""
	var rawParametersToCall: String = ""

	init(name: String? = nil, method: String? = nil, url: String? = nil, parameters: [String: String] = [:], rawParameters: String = "", rawParametersWithoutType: String = "", parametersEntity: [ParametersToWrite] = [], queryParameters: [ParametersToWrite] = [], pathParameters: [ParametersToWrite] = [], queryParametersStringDictPresentation: String = "", requestBodyString: String = "", requestBodyStringValueName: String = "", responseString: String = "", responseStringValueName: String = "", rawParametersToCall: String = "") {
        self.name = name
        self.method = method
        self.url = url
        self.parameters = parameters
        self.rawParameters = rawParameters
		self.rawParametersWithoutType = rawParametersWithoutType
		self.parametersEntity = parametersEntity
		self.queryParameters = queryParameters
		self.pathParameters = pathParameters
		self.queryParametersStringDictPresentation = queryParametersStringDictPresentation
		self.requestBodyString = requestBodyString
		self.requestBodyStringValueName = requestBodyStringValueName
		self.responseString = responseString
		self.responseStringValueName = responseStringValueName
		self.rawParametersToCall = rawParametersToCall
    }

    var description: String {
        return "name: \(name), method: \(method), url: \(url), parameters: \(parameters)"
    }

	func updateURLToMoya() {
//		if self.url?.contains("{") ?? false {
//			var rawURL = self.url?.components(separatedBy: "{").first ?? "/"
//			rawURL = "\(rawURL)\\(\(self.parameters.first?.key ?? ""))"
//			self.url = rawURL
//		}
		if self.url?.contains("{") ?? false {
			self.url = self.url?.replacingOccurrences(of: "{", with: "\\(")
			self.url = self.url?.replacingOccurrences(of: "}", with: ")")
		}
	}

	//to one string
	func createRawParameters() {
		let raw = self.parameters.map { (key, value) -> String in
		    return "\(key): \(value)"
	    }.joined(separator: ", ")

		self.rawParameters = raw

		self.createRawParametersToCall()
	}

	func createRawParametersToCall() {
		let raw = self.parameters.map { (key, value) -> String in
		    return "\(key): \(key)"
	    }.joined(separator: ", ")

		self.rawParametersToCall = raw
	}

	func createRawParametersWithoutType() {
		let raw = self.parameters.map {  (key, value) -> String in
			return "\(key)"
		}.joined(separator: ", ")

		self.rawParametersWithoutType = raw
	}

	func createParameters(from operation: SwaggerOperation) {
		operation.parameters?.forEach { parameter in
			var rawParameter = ParametersToWrite(name: (parameter.value?.metadata.name)!)
			rawParameter.isRequired = parameter.value?.metadata.isRequired

			switch parameter.value?.serialization {
			case let .schema(schema):
				switch schema.schema.value?.type {
				case .string:
					rawParameter.type = "String"
					self.parameters.updateValue("String", forKey: (parameter.value?.metadata.name)!)

				case .integer:
					rawParameter.type = "Int"
					self.parameters.updateValue("Int", forKey: (parameter.value?.metadata.name)!)

				case .boolean:
					rawParameter.type = "Bool"
					self.parameters.updateValue("Bool", forKey: (parameter.value?.metadata.name)!)

				case let .array(arraySchema):
					switch arraySchema.itemsSchema.type {
					case let .value(value):
						switch value.type {
						case .string:
							rawParameter.type = "[String]"
							self.parameters.updateValue("[String]", forKey: parameter.value?.metadata.name ?? "UnknownParameterName")
						case .integer:
							rawParameter.type = "[Int]"
							self.parameters.updateValue("[Int]", forKey: parameter.value?.metadata.name ?? "UnknownParameterName")
						default:
							break
						}
					default:
						break
					}

				default:
					break
				}
			default:
				break
			}

			switch parameter.value?.metadata.type {
			case .path:
				rawParameter.isInPath = true
				self.pathParameters.append(rawParameter)

			case .query:
				rawParameter.isInQuery = true
				self.queryParameters.append(rawParameter)

			case .none:
				break

			case .some(.header):
				break

			case .some(.cookie):
				break
			}

			self.parametersEntity.append(rawParameter)
		}

		if self.queryParameters.count > 0 && self.queryParametersStringDictPresentation.contains("[") == false {
			self.queryParameters.forEach { element in
				self.queryParametersStringDictPresentation.append("\"\(element.name)\": \(element.name), ")
			}

			self.queryParametersStringDictPresentation.removeLast()
			self.queryParametersStringDictPresentation.removeLast()

			self.queryParametersStringDictPresentation = "[\(self.queryParametersStringDictPresentation)]"
		}
	}

	func checkResponse(with operation: SwaggerOperation) {
		var response: SwaggerComponent<SwaggerResponse>!

		if operation.responses["200"] != nil {
			response = operation.responses["200"]!
		} else if (operation.responses["default"] != nil) {
			response = operation.responses["default"]!
		} else {
			self.responseString = "Void"
			self.responseStringValueName = "Void"
			return
		}



//		if let response = operation.responses["200"], let defaultResponse = operation.responses["default"] {
			switch response.type {
			case let .reference(referenceValue):
				print(referenceValue)

			case let .value(value):
				let content = value.content?["application/json"]

				if content == nil {
					self.responseString = "Void"
					self.responseStringValueName = "Void"
				}

				switch content?.schema?.type {
				case let .value(schemaValue):
					switch schemaValue.type {
					case let .array(arraySchema):

						switch arraySchema.itemsSchema.type {
						case let .reference(arraySchemaValue):
//							print("[\(arraySchemaValue.uri.components(separatedBy: "/").last ?? "Unknown" )]")
							self.responseString = "[\(arraySchemaValue.uri.components(separatedBy: "/").last ?? "Unknown" )"

						default:
							break
						}

					case .string:
						self.responseString = "String"

					case .integer:
						self.responseString = "Int"

					case .boolean:
						self.responseString = "Bool"

					default:
						break
					}

				case let .reference(schemaReferenceValue):
					switch schemaReferenceValue.component?.value?.type {
					case let .array(arraySchema):

						switch arraySchema.itemsSchema.type {
						case let .reference(arraySchemaValue):
//							print("[\(arraySchemaValue.uri.components(separatedBy: "/").last ?? "Unknown" )]")
							self.responseString = "[\(arraySchemaValue.uri.components(separatedBy: "/").last ?? "Unknown" )"

						default:
							break
						}

					case let .object(objectSchema):
						self.responseString = schemaReferenceValue.uri.components(separatedBy: "/").last ?? "Unknown"

					default:
						break

					}

				default:
					break
				}

			default:
				break
			}

			if self.responseString.contains("[") {
				var key = self.responseString
				var value = self.responseString

				key = key.replacingOccurrences(of: "[", with: "")
				key = key.lowercased()
				key.append("s")

				value.append("]")


				self.responseString = key
				self.responseStringValueName = value

			} else if responseString != "" {

				self.responseStringValueName = self.responseString.firstCapitalized
			}
//		}
	}

	func checkRequestBody(with operation: SwaggerOperation) {
		switch operation.requestBody?.type {
		case let .reference(referenceValue):
			print(referenceValue)

		case let .value(value):
			let content = value.content["application/json"]

			switch content?.schema?.type {
			case let .value(schemaValue):
				switch schemaValue.type {
				case let .array(arraySchema):

					switch arraySchema.itemsSchema.type {
					case let .reference(arraySchemaValue):
//						print("[\(arraySchemaValue.uri.components(separatedBy: "/").last ?? "Unknown" )]")
						self.requestBodyString = "[\(arraySchemaValue.uri.components(separatedBy: "/").last ?? "Unknown" )"

					default:
						break
					}

				default:
					break
				}

			case let .reference(schemaReferenceValue):
				switch schemaReferenceValue.component?.value?.type {
				case let .array(arraySchema):

					switch arraySchema.itemsSchema.type {
					case let .reference(arraySchemaValue):
//						print("[\(arraySchemaValue.uri.components(separatedBy: "/").last ?? "Unknown" )]")
						self.requestBodyString = "[\(arraySchemaValue.uri.components(separatedBy: "/").last ?? "Unknown" )"

					default:
						break
					}

				case let .object(objectSchema):
					self.requestBodyString = schemaReferenceValue.uri.components(separatedBy: "/").last ?? "Unknown"
					

				default:
					break

				}

			default:
				break
			}

		default:
			break
		}

		if self.requestBodyString.contains("[") {
			var key = self.requestBodyString
			var value = self.requestBodyString

			key = key.replacingOccurrences(of: "[", with: "")
			key = key.lowercased()
			key.append("s")

			value.append("]")

			self.requestBodyStringValueName = key

			self.parameters.updateValue(value, forKey: key)
		} else if requestBodyString != "" {
			self.parameters.updateValue(self.requestBodyString, forKey: self.requestBodyString.lowercased())

			self.requestBodyStringValueName = self.requestBodyString.lowercased()
		}
	}
}
