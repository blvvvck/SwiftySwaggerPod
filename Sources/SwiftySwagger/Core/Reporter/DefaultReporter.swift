//
//  DefaultReporter.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 31.05.2020.
//

import Foundation
import SwiftCLI

class DefaultReporter: Reporter {
	func report(info: String) {
		WriteStream.stdout <<< info
	}

	static func report(info: String) {
//        stdout <<< "Hey there, \(person)!"
		WriteStream.stdout <<< info
	}
}
