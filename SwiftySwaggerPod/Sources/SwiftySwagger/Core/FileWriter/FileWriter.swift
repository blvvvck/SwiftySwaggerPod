//
//  FileWriter.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 31.05.2020.
//

import Foundation
import PathKit

protocol FileWriter {
	func write(sourceCode: String, path: Path)
}
