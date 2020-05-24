//
//  HiClass.swift
//  
//
//  Created by Kevin Turner on 5/21/20.
//

import Foundation

class HiClass: HiCallable, CustomStringConvertible {
    var description: String {
        get {
            return name
        }
    }
    
    let name: String
    let methods: Dictionary<String, HiFunction>
    let superclass: HiClass?
    
    init(name: String, methods: Dictionary<String, HiFunction>, superclass: HiClass?) {
        self.name = name
        self.methods = methods
        self.superclass = superclass
    }
    
    func findMethod(name: String) -> HiFunction? {
        if methods.keys.contains(name) {
            return methods[name]
        }
        
        if let superclass = self.superclass {
            return superclass.findMethod(name: name)
        }
        
        return nil
    }
    
    func arity() -> Int {
        if let initializer = findMethod(name: "init") {
            return initializer.arity()
        }
        
        return 0
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        let instance = HiInstance(klass: self)
        if let initializer = findMethod(name: "init") {
            _ = try initializer.bind(instance: instance).call(interpreter, args: args)
        }
        return instance
    }
    
    
    
}
