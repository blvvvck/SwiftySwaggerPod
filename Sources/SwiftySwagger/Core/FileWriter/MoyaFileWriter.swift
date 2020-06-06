//
//  MoyaFileWriter.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 31.05.2020.
//

import Foundation
import PathKit

class MoyaFileWriter: FileWriter {
	func write(sourceCode: String, path: Path) {
		do {
			try path.write(sourceCode)
		} catch {
			DefaultReporter.report(info: "Error while writing")
		}
	}
}
