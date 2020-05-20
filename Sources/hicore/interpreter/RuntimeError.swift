//
//  RuntimeError.swift
//  
//
//  Created by Kevin Turner on 5/18/20.
//

import Foundation


struct RuntimeError: Error {
    let tok: Token
    let message: String
}

struct ArgumentError: Error {}

struct ReturnExcept: Error {
    let val: Any?
}
