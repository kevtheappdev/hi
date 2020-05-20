//
//  hiCallable.swift
//  
//
//  Created by Kevin Turner on 5/20/20.
//

import Foundation

protocol HiCallable {
    func arity() -> Int
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any?
}
