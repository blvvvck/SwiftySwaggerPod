//
//  ParametersToWrite.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 05.05.2020.
//  Copyright © 2020 Ринат Мухамметзянов. All rights reserved.
//

import Foundation

class ParametersToWrite: CustomStringConvertible {
	var name: String
	var type: String
	var isInPath: Bool?
	var isInQuery: Bool?
	var isRequired: Bool?

	init(name: String, type: String = "", isInPath: Bool? = false, isInQuery: Bool? = false, isRequired: Bool? = true) {
		self.name = name
		self.type = type
		self.isInPath = isInPath
		self.isInQuery = isInQuery
		self.isRequired = isRequired
	}

	var description: String {
		return ""
	}
}
