//
//  HiInstance.swift
//  
//
//  Created by Kevin Turner on 5/21/20.
//

import Foundation

class HiInstance: CustomStringConvertible {
    private let klass: HiClass
    private var fields = Dictionary<String, Any?>()
    
    init(klass: HiClass) {
        self.klass = klass
    }
    
    func get(index: Token) throws -> Any? {
        if let val = fields[index.lexeme] {
            return val
        }
        
        let method = klass.findMethod(name: index.lexeme)
        if method != nil { return method?.bind(instance: self) }
        
        throw RuntimeError(tok: index, message: "Undefined property '\(index.lexeme).'")
    }
    
    func set(name: Token, val: Any?) {
        fields[name.lexeme] = val
    }
    
    var description: String {
        get {
            return "\(klass.name) instance"
        }
    }
}
