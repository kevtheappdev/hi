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
    
    func get(name: Token) -> Any? {
        if values.keys.contains(name.lexeme) {
            return values[name.lexeme]!
        }
        
        if let enclosingEnviron = enclosing {
            return enclosingEnviron.get(name: name)
        }
        
        return nil // TODO: error out here
    }
    
    func assign(name: Token, value: Any?) {
        if values.keys.contains(name.lexeme) {
            values[name.lexeme] = value
        } else {
            if let enclosingEnviron = enclosing {
                enclosingEnviron.assign(name: name, value: value)
                return
            }
            
            fatalError("Undefined Variable") // TODO: throw proper exception
        }
    }
}
