//
//  ModelGenerator.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 05.05.2020.
//  Copyright © 2020 Ринат Мухамметзянов. All rights reserved.
//

import Foundation
import PathKit
import Stencil
import SwiftCLI

class ModelGenerator: Generator {
	let swagger: Swagger
	let path: Path

	init(specification: Swagger, and path: Path) {
		self.swagger = specification
		self.path = path
	}

	func generate(with swagger: Swagger, path: Path, templateName: String?) {
		var entityToWrite = [EntityToWrite]()

		swagger.spec.components?.schemas?.forEach({ (key, value) in
            let entity = EntityToWrite(name: key)

            switch value.value?.type {
            case let .object(schema):
                schema.properties?.forEach({ (name, type) in
                    switch type.value?.type {
                    case .integer:
                        entity.properties.updateValue("Int", forKey: name)

                    case .string:
                        entity.properties.updateValue("String", forKey: name)

					case let .array(arraySchema):

						switch arraySchema.itemsSchema.type {
						case let .reference(arraySchemaValue):
							entity.properties.updateValue("[\(arraySchemaValue.uri.components(separatedBy: "/").last ?? "Unknown" )]", forKey: name)

						default:
							break
						}

                    default:
                        break
                    }
                })

                entityToWrite.append(entity)
            default:
                break
            }
        })

//        print(entityToWrite)

		try? FileManager.default.createDirectory(atPath: self.path.appending("API").string, withIntermediateDirectories: false, attributes: nil)
		try? FileManager.default.createDirectory(atPath: self.path.appending("API/Models").string, withIntermediateDirectories: false, attributes: nil)

        try! entityToWrite.forEach {
            let context = [
                "model": $0
            ]

//			let environment = Environment(loader: FileSystemLoader(paths: [Path(Bundle.main.resourcePath!)]))
			let environment = Environment(loader: FileSystemLoader(paths: [self.path.appending("Templates")]))

            let rendered = try! environment.renderTemplate(name: "Model.stencil", context: context)

//            let path = Path("/Users/rmuhammetzyanov/Downloads/SwiftySwagger/Templates/Models/\($0.name).swift")
			let path = self.path.appending("API/Models/\($0.name).swift")
            try! path.write(rendered, encoding: .utf8)
        }
	}
}
