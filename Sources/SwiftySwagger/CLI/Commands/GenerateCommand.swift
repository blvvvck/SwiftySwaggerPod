//
//  GenerateCommand.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 26.05.2020.
//

import Foundation
import SwiftCLI
import PathKit

class GenerateCommand: Command {
    let name = "generate"

    @Param
	var specificationURL: String

    @Param
	var templateName: String?

    func execute() throws {
		if specificationURL.isValidURL {
			if let specification = try? Swagger(url: URL(string: specificationURL)!) {
				let modelGenerator = ModelGenerator(specification: specification, and: Path.current)
				modelGenerator.generate(with: specification, path: Path.current, templateName: templateName)

				let generator: Generator = DefaultGenerator()
				generator.generate(with: specification, path: Path.current, templateName: templateName)

			} else {
				stdout <<< "Incorrect Specification"
			}
		} else {
			stdout <<< "Incorrect URL"
		}
    }
}




extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}
