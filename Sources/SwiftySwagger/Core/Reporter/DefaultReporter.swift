//
//  DefaultReporter.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 31.05.2020.
//

import Foundation

class DefaultReporter: Reporter {
	func report(info: String) {
		print(info)
	}

	static func report(info: String) {
//        stdout <<< "Hey there, \(person)!"
		print(info)
	}
}
