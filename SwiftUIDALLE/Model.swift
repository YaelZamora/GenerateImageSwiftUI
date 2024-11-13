//
//  Model.swift
//  SwiftUIDALLE
//
//  Created by Yael Javier Zamora Moreno on 13/11/24.
//

import Foundation

struct DataResponse: Decodable {
    let url: String
}

struct ModelResponse: Decodable {
    let data: [DataResponse]
}
