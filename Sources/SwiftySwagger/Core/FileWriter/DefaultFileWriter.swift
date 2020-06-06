//
//  DefaultFileWriter.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 31.05.2020.
//

import Foundation
import PathKit

class DefaultFileWriter {
	static func write(sourceCode: String, path: Path) {
		do {
			try path.write(sourceCode, encoding: .utf8)
		} catch {
			DefaultReporter.report(info: "Error while writing in \(path.string)")
		}
	}
}
