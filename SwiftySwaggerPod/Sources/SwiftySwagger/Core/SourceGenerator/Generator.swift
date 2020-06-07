//
//  Generator.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 05.05.2020.
//  Copyright © 2020 Ринат Мухамметзянов. All rights reserved.
//

import Foundation
import PathKit

protocol Generator {
	func generate(with swagger: Swagger, path: Path, templateName: String?)
}
