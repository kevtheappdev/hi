//
//  File.swift
//  
//
//  Created by Kevin Turner on 5/20/20.
//

import Foundation

class HiFunction: HiCallable {
    let declaration: Function
    let closure: Environment
    let isInitializer: Bool
    
    init(declaration: Function, closure: Environment, isInitializer: Bool = false) {
        self.declaration = declaration
        self.closure = closure
        self.isInitializer = isInitializer
    }
    
    func bind(instance: HiInstance) -> HiFunction {
        let environment = Environment(enclosing: closure)
        environment.define(name: "self", value: instance)
        return HiFunction(declaration: declaration, closure: environment, isInitializer: isInitializer)
    }
    
    func arity() -> Int {
        return declaration.params.count
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        let environ = Environment(enclosing: self.closure)
        for i in 0..<args.count {
            let param = declaration.params[i]
            environ.define(name: param.lexeme, value: args[i])
        }
        
        do {
            try interpreter.executeBlock(stmts: declaration.body, environ: environ)
        } catch let returnStmt as ReturnExcept {
            if isInitializer { return try closure.get(AtDistance: 0, name: "self")}
            if let returnVal = returnStmt.val {
                return returnVal
            }
        }
        
        if isInitializer { return try closure.get(AtDistance: 0, name: "self") }
        return nil
    }
}
