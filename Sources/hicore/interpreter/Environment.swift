//
//  Environment.swift
//  
//
//  Created by Kevin Turner on 5/19/20.
//

import Foundation

class Environment {
    private var values = Dictionary<String, Any?>()
    var enclosing: Environment? = nil
    
    init() {}
    
    init(enclosing: Environment) {
        self.enclosing = enclosing
    }
    
    func define(name: String, value: Any?) {
        values[name] = value
    }
    
    func get(name: Token) throws -> Any? {
        if values.keys.contains(name.lexeme) {
            return values[name.lexeme]!
        }
        
        if let enclosingEnviron = enclosing {
            return try enclosingEnviron.get(name: name)
        }
        
        throw RuntimeError(tok: name, message: "Undefined variable: \(name.lexeme).")
    }
    
    func assign(name: Token, value: Any?) throws {
        if values.keys.contains(name.lexeme) {
            values[name.lexeme] = value
        } else {
            if let enclosingEnviron = enclosing {
                try enclosingEnviron.assign(name: name, value: value)
                return
            }
            
            throw RuntimeError(tok: name, message: "Attempting to assign to undefined variable: \(name.lexeme)")
        }
    }
}
