//
//  Math.swift
//  
//
//  Created by Kevin Turner on 5/20/20.
//

import Foundation

class Sin: HiCallable {
    func arity() -> Int {
        return 1
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        if !(args[0] is Double) { throw ArgumentError() }
        return sin(args[0] as! Double)
    }
}


class Cos: HiCallable {
    func arity() -> Int {
        return 1
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        if !(args[0] is Double) { throw ArgumentError() }
        return cos(args[0] as! Double)
    }
}

class Tan: HiCallable {
    func arity() -> Int {
        return 1
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        if !(args[0] is Double) { throw ArgumentError() }
        return tan(args[0] as! Double)
    }
}

class Round: HiCallable {
    func arity() -> Int {
        return 1
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        if !(args[0] is Double) { throw ArgumentError() }
        return round(args[0] as! Double)
    }
}
