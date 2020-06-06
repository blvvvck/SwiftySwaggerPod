//
//  MoyaGenerator.swift
//  ArmatureTests
//
//  Created by Мухамметзянов Ринат Зиннурович on 30.05.2020.
//

import Foundation
import StencilSwiftKit
import Stencil
import PathKit

class DefaultGenerator: Generator {
	func generate(with swagger: Swagger, path: Path, templateName: String?) {

		if let templateName = templateName {
			switch templateName {
			case "Moya":
				let modelsForGenerate = generateTemplateModel(swagger: swagger, path: path, templateName: templateName)

				generateBaseTargetType(swagger: swagger, path: path)
				writeMoyaTemplate(modelsForGenerate: modelsForGenerate, path: path)

			case "URLSession":
				let modelsForGenerate = generateTemplateModel(swagger: swagger, path: path, templateName: templateName)

				URLSessionFileWriter().writeBaseFiles(path: path)
				generateBaseEndPointType(swagger: swagger, path: path)
				writeURLSessionTemplate(modelsForGenerate: modelsForGenerate, path: path)

			case "Alamofire":
				let modelsForGenerate = generateTemplateModel(swagger: swagger, path: path, templateName: templateName)

				AlamofireFileWriter().writeBaseFiles(path: path)
				generateAlamofireBaseTargetType(swagger: swagger, path: path)
				writeAlamofireTemplate(modelsForGenerate: modelsForGenerate, path: path)
				
			default:
				if FileManager.default.fileExists(atPath: path.appending("Templates/\(templateName).stencil").string) {
					let modelsForGenerate = generateTemplateModel(swagger: swagger, path: path, templateName: templateName)

					writeCustomTemplate(modelsForGenerate: modelsForGenerate, path: path, templateName: templateName)
				} else {
					DefaultReporter.report(info: "Template doesn't exists!")
				}
			}
		} else {
			let modelsForGenerate = generateTemplateModel(swagger: swagger, path: path, templateName: templateName)

			writeMoyaTemplate(modelsForGenerate: modelsForGenerate, path: path)
		}
	}

	private func writeCustomTemplate(modelsForGenerate: [String: [RequestToWrite]], path: Path, templateName: String) {
		try? FileManager.default.createDirectory(atPath: path.appending("API").string, withIntermediateDirectories: false, attributes: nil)
		try? FileManager.default.createDirectory(atPath: path.appending("API/Custom").string, withIntermediateDirectories: false, attributes: nil)

		modelsForGenerate.forEach { (tag, requests) in
			let context = [
				"models": requests,
				"tag": tag.firstCapitalized
			] as [String : Any]

			let ext = Extension()
			ext.registerStencilSwiftExtensions()
			let environment = Environment(loader: FileSystemLoader(paths: [path.appending("Templates")]), extensions: [ext], templateClass: StencilSwiftTemplate.self)

			do {
				let rendered = try environment.renderTemplate(name: "\(templateName).stencil", context: context)
				let path = path.appending("API/Custom/\(tag.firstCapitalized)\(templateName).swift")

				DefaultFileWriter.write(sourceCode: rendered, path: path)
			} catch {
				DefaultReporter.report(info: "Incorrect template")
			}
		}

		DefaultReporter.report(info: "Successfully generated!")
	}

	private func writeAlamofireTemplate(modelsForGenerate: [String: [RequestToWrite]], path: Path) {
		try? FileManager.default.createDirectory(atPath: path.appending("API").string, withIntermediateDirectories: false, attributes: nil)
		try? FileManager.default.createDirectory(atPath: path.appending("API/Endpoint").string, withIntermediateDirectories: false, attributes: nil)
		try? FileManager.default.createDirectory(atPath: path.appending("API/Services").string, withIntermediateDirectories: false, attributes: nil)

		modelsForGenerate.forEach { (tag, requests) in
			let context = [
				"models": requests,
				"tag": tag.firstCapitalized
			] as [String : Any]

			let ext = Extension()
			ext.registerStencilSwiftExtensions()
			let environment = Environment(loader: FileSystemLoader(paths: [path.appending("Templates")]), extensions: [ext], templateClass: StencilSwiftTemplate.self)

			do {
				let rendered = try environment.renderTemplate(name: "AlamofireAPI.stencil", context: context)
				let path = path.appending("API/Endpoint/\(tag.firstCapitalized)API.swift")

				DefaultFileWriter.write(sourceCode: rendered, path: path)
			} catch {
				DefaultReporter.report(info: "Incorrect template")
			}
		}

		modelsForGenerate.forEach { (tag, requests) in
			let context = [
				"models": requests,
				"tag": tag.firstCapitalized
			] as [String : Any]

			let ext = Extension()
			ext.registerStencilSwiftExtensions()
			let environment = Environment(loader: FileSystemLoader(paths: [path.appending("Templates")]), extensions: [ext], templateClass: StencilSwiftTemplate.self)

			do {
				let rendered = try environment.renderTemplate(name: "AlamofireService.stencil", context: context)
				let path = path.appending("API/Services/\(tag.firstCapitalized)Service.swift")

				DefaultFileWriter.write(sourceCode: rendered, path: path)
			} catch {
				DefaultReporter.report(info: "Incorrect template")
			}
		}

		DefaultReporter.report(info: "Successfully generated!")
	}

	private func writeURLSessionTemplate(modelsForGenerate: [String: [RequestToWrite]], path:Path) {
		try? FileManager.default.createDirectory(atPath: path.appending("API").string, withIntermediateDirectories: false, attributes: nil)
		try? FileManager.default.createDirectory(atPath: path.appending("API/Endpoint").string, withIntermediateDirectories: false, attributes: nil)
		try? FileManager.default.createDirectory(atPath: path.appending("API/Services").string, withIntermediateDirectories: false, attributes: nil)

		modelsForGenerate.forEach { (tag, requests) in
			let context = [
				"models": requests,
				"tag": tag.firstCapitalized
			] as [String : Any]

			let ext = Extension()
			ext.registerStencilSwiftExtensions()
			let environment = Environment(loader: FileSystemLoader(paths: [path.appending("Templates")]), extensions: [ext], templateClass: StencilSwiftTemplate.self)

			do {
				let rendered = try environment.renderTemplate(name: "URLSessionAPI.stencil", context: context)
				let path = path.appending("API/Endpoint/\(tag.firstCapitalized)API.swift")

				DefaultFileWriter.write(sourceCode: rendered, path: path)
			} catch {
				DefaultReporter.report(info: "Incorrect template")
			}
		}

		modelsForGenerate.forEach { (tag, requests) in
			let context = [
				"models": requests,
				"tag": tag.firstCapitalized
			] as [String : Any]

			let ext = Extension()
			ext.registerStencilSwiftExtensions()
			let environment = Environment(loader: FileSystemLoader(paths: [path.appending("Templates")]), extensions: [ext], templateClass: StencilSwiftTemplate.self)

			do {
				let rendered = try environment.renderTemplate(name: "URLSessionService.stencil", context: context)
				let path = path.appending("API/Services/\(tag.firstCapitalized)Service.swift")

				DefaultFileWriter.write(sourceCode: rendered, path: path)
			} catch {
				DefaultReporter.report(info: "Incorrect template")
			}
		}

		DefaultReporter.report(info: "Successfully generated!")
	}

	private func writeMoyaTemplate(modelsForGenerate: [String: [RequestToWrite]], path: Path) {
		try? FileManager.default.createDirectory(atPath: path.appending("API").string, withIntermediateDirectories: false, attributes: nil)
		try? FileManager.default.createDirectory(atPath: path.appending("API/Providers").string, withIntermediateDirectories: false, attributes: nil)
		try? FileManager.default.createDirectory(atPath: path.appending("API/Services").string, withIntermediateDirectories: false, attributes: nil)


		modelsForGenerate.forEach { (tag, requests) in
			let context = [
				"models": requests,
				"tag": tag.firstCapitalized
			] as [String : Any]

			let ext = Extension()
			ext.registerStencilSwiftExtensions()
			let environment = Environment(loader: FileSystemLoader(paths: [path.appending("Templates")]), extensions: [ext], templateClass: StencilSwiftTemplate.self)
//			let environment = Environment(loader: FileSystemLoader(paths: [path.appending("Templates")]))

			do {
				let rendered = try environment.renderTemplate(name: "MoyaAPI.stencil", context: context)
				let path = path.appending("API/Providers/\(tag.firstCapitalized)Provider.swift")

				DefaultFileWriter.write(sourceCode: rendered, path: path)
			} catch {
				DefaultReporter.report(info: "Incorrect template")
			}

//			let rendered = try! environment.renderTemplate(name: "MoyaAPI.stencil", context: context)
//
//			let path = path.appending("API/Providers/\(tag.firstCapitalized)Provider.swift")
//
////			print(rendered)
//			try? path.write(rendered, encoding: .utf8)
		}

		modelsForGenerate.forEach { (tag, requests) in
			let context = [
				"models": requests,
				"tag": tag.firstCapitalized
			] as [String : Any]

			let ext = Extension()
			ext.registerStencilSwiftExtensions()
			let environment = Environment(loader: FileSystemLoader(paths: [path.appending("Templates")]), extensions: [ext], templateClass: StencilSwiftTemplate.self)
//			let environment = Environment(loader: FileSystemLoader(paths: [path.appending("Templates")]))

			do {
				let rendered = try environment.renderTemplate(name: "MoyaServices.stencil", context: context)
				let path = path.appending("API/Services/\(tag.firstCapitalized)Service.swift")

				DefaultFileWriter.write(sourceCode: rendered, path: path)
			} catch {
				DefaultReporter.report(info: "Incorrect template")
			}

			DefaultReporter.report(info: "Successfully generated!")


//			let rendered = try! environment.renderTemplate(name: "MoyaServices.stencil", context: context)
//
//			let path = path.appending("API/Services/\(tag.firstCapitalized)Service.swift")
//
//			try? path.write(rendered, encoding: .utf8)
		}
	}

	private func generateTemplateModel(swagger: Swagger, path: Path, templateName: String?) -> [String: [RequestToWrite]] {
		var taggedRequest = [String: [RequestToWrite]]()
		var requests = [RequestToWrite]()

		swagger.spec.paths.forEach({ (stringPath, path) in
			// TODO
			if path.value?.get?.identifier == "getInventory" {
				return
			}

			if let getOperation = path.value?.get {
				let request = RequestToWrite()
				request.url = stringPath
				request.name = getOperation.identifier
				request.method = "get"
				request.createParameters(from: getOperation)
				request.createRawParameters()
				request.createRawParametersWithoutType()

				request.updateURLToMoya()

				request.checkResponse(with: getOperation)

				requests.append(request)

				let tag = getOperation.tags?.first ?? "UnknownTag"

				if var tagged = taggedRequest[tag] {
					tagged.append(request)
					taggedRequest.updateValue(tagged, forKey: tag)
				} else {
					taggedRequest.updateValue([request], forKey: tag)
				}
			}

			if let postOperation = path.value?.post {
				let request = RequestToWrite()
				request.url = stringPath

				request.name = postOperation.identifier
				request.method = "post"

				request.checkRequestBody(with: postOperation)
				request.createParameters(from: postOperation)
				request.createRawParameters()
				request.createRawParametersWithoutType()
				request.updateURLToMoya()
				request.checkResponse(with: postOperation)

				requests.append(request)

				let tag = postOperation.tags?.first ?? "UnknownTag"

				if var tagged = taggedRequest[tag] {
					tagged.append(request)
					taggedRequest.updateValue(tagged, forKey: tag)
				} else {
					taggedRequest.updateValue([request], forKey: tag)
				}
			}

			if let putOperation = path.value?.put {
				let request = RequestToWrite()
				request.url = stringPath

				request.name = putOperation.identifier
				request.method = "put"

				request.checkRequestBody(with: putOperation)
				request.createParameters(from: putOperation)
				request.createRawParameters()
				request.createRawParametersWithoutType()
				request.updateURLToMoya()
				request.checkResponse(with: putOperation)

				requests.append(request)

				let tag = putOperation.tags?.first ?? "UnknownTag"

				if var tagged = taggedRequest[tag] {
					tagged.append(request)
					taggedRequest.updateValue(tagged, forKey: tag)
				} else {
					taggedRequest.updateValue([request], forKey: tag)
				}
			}
		})

		return taggedRequest
	}

	// TODO
	private func generateBaseTargetType(swagger: Swagger, path: Path) {
		let context = [
			"baseURL": "https://petstore3.swagger.io\(swagger.spec.servers?.first!.url ?? "")"
		]

		let environment = Environment(loader: FileSystemLoader(paths: [path.appending("Templates")]))

		do {
			let rendered = try environment.renderTemplate(name: "BaseTargetType.stencil", context: context as [String : Any])
			let path = path.appending("API/BaseTargetType.swift")

			DefaultFileWriter.write(sourceCode: rendered, path: path)
		} catch {
			DefaultReporter.report(info: "Incorrect template")
		}
	}

	private func generateBaseEndPointType(swagger: Swagger, path: Path) {
		let context = [
			"baseURL": "https://petstore3.swagger.io\(swagger.spec.servers?.first!.url ?? "")"
		]

		let environment = Environment(loader: FileSystemLoader(paths: [path.appending("Templates")]))

		do {
			let rendered = try environment.renderTemplate(name: "BaseEndPointType.stencil", context: context as [String : Any])
			let path = path.appending("API/BaseEndPoint.swift")

			DefaultFileWriter.write(sourceCode: rendered, path: path)
		} catch {
			DefaultReporter.report(info: "Incorrect template")
		}
	}


	private func generateAlamofireBaseTargetType(swagger: Swagger, path: Path) {
		let context = [
			"baseURL": "https://petstore3.swagger.io\(String(swagger.spec.servers?.first!.url ?? ""))"
		]

		let environment = Environment(loader: FileSystemLoader(paths: [path.appending("Templates")]))

		do {
			let rendered = try environment.renderTemplate(name: "AlamofireBaseTargetType.stencil", context: context as [String : Any])
			let path = path.appending("API/BaseTargetType.swift")

			DefaultFileWriter.write(sourceCode: rendered, path: path)
		} catch {
			DefaultReporter.report(info: "Incorrect template")
		}
	}
}
