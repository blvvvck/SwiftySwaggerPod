//
//  EntityToWrite.swift
//  SwiftySwagger
//
//  Created by Мухамметзянов Ринат Зиннурович on 05.05.2020.
//  Copyright © 2020 Ринат Мухамметзянов. All rights reserved.
//

import Foundation

class EntityToWrite {
    let name: String
    var properties: [String: String] = [:]

	init(name: String, properties: [String: String] = [:]) {
        self.name = name
        self.properties = properties

    }
}

