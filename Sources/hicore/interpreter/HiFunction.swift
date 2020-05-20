//
//  File.swift
//  
//
//  Created by Kevin Turner on 5/20/20.
//

import Foundation

struct HiFunction: HiCallable {
    let declaration: Function
    
    func arity() -> Int {
        return declaration.params.count
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        let environ = Environment(enclosing: interpreter.globals)
        for i in 0..<args.count {
            let param = declaration.params[i]
            environ.define(name: param.lexeme, value: args[i])
        }
        
        do {
            try interpreter.executeBlock(stmts: declaration.body, environ: environ)
        } catch let returnStmt as ReturnExcept {
            if let returnVal = returnStmt.val {
                return returnVal
            }
        }
        
        return nil
    }
}
