//
//  Interpreter.swift
//  
//
//  Created by Kevin Turner on 5/18/20.
//

import Foundation

public class Interpreter {
    var environment = Environment()
    
    public init() {}
    
    public func interpret(statements: Array<Stmt>) -> Swift.Result<(), Error> {
        // TODO: implement error handling
        for statement in statements {
            execute(stmt: statement)
        }
        
        return .success(())
    }
    
    private func execute(stmt: Stmt) {
        _ = stmt.acceptVisitor(visitor: self) as Any
    }
    
    private func executeBlock(stmts: Array<Stmt>, environ: Environment) {
        let prev = self.environment
        defer {
            self.environment = prev
        }
        
        self.environment = environ
        
        for stmt in stmts {
             execute(stmt: stmt)
        }
    }
    
    private func stringify(_ obj: Any?) -> String {
        guard let nonNilObj = obj else { return "nada" }
        
        if nonNilObj is Double {
            return String(nonNilObj as! Double)
        }
        
        if nonNilObj is String {
            return nonNilObj as! String
        }
        
        if nonNilObj is Bool {
            let bool = nonNilObj as! Bool
            return bool ? "yerr" : "nah"
        }
        
        fatalError("unexpected type in stringify")
    }
        
    private func isEqual<T: Equatable>(_ a: T?, b: T?) -> Bool {
        if a == nil && b == nil { return true }
        if b == nil { return false }
        
        return a == b
    }
    
    private func isTruthy(_ obj: Any?) -> Bool {
        if obj == nil { return false }
        if obj is Bool { return obj as! Bool}
        return true
    }
    
    private func evaluate(_ expr: Expr) -> Any? {
        return expr.acceptVisitor(visitor: self)
    }
    
    public typealias R = Any?
    
}

// MARK: Expression Visitors
extension Interpreter: ExprVisitor {
    public func visitAssignExpr(expr: Assign) -> Any? {
        let val = evaluate(expr.value)
        
        environment.assign(name: expr.name, value: val)
        return val
    }
    
    public func visitVariableExpr(expr: Variable) -> Any? {
        return environment.get(name: expr.name)
    }
    
    public func visitBinaryExpr(expr: Binary) -> Any? {
        let left = evaluate(expr.left)
        let right = evaluate(expr.right)
        
        switch expr.op.tokenType { // TODO: error check casts to Double, take care of PLUS operator (strings and double types)
        case .MINUS:
            return (left as! Double) - (right as! Double)
        case .SLASH:
            return (left as! Double) / (right as! Double)
        case .STAR:
            return (left as! Double) * (right as! Double)
        case .GREATER:
            return (left as! Double) > (right as! Double)
        case .GREATER_EQUALS:
            return (left as! Double) >= (right as! Double)
        case .LESS:
            return (left as! Double) < (right as! Double)
        case .LESS_EQUALS:
            return (left as! Double) <= (right as! Double)
        case .BANG:
            return isEqual((left as! Double), b: (right as! Double))
        case .PLUS:
            return (left as! Double) + (right as! Double)
        default:
            print("Invalid operator for Binary expression")
            return nil
        }
    }
    
    public func visitGroupingExpr(expr: Grouping) -> Any? {
        return evaluate(expr.expression)
    }
    
    public func visitLiteralExpr(expr: Literal) -> Any? {
        return expr.value // TODO: unwrap gracefully
    }
    
    
    public func visitUnaryExpr(expr: Unary) -> Any? {
        let right = evaluate(expr.right)
        
        switch expr.op.tokenType {
        case .MINUS:
            return -(right as! Double)
        case .BANG:
            return !isTruthy(right)
        default:
            fatalError("Invalid Unary operator")
        }
    }

}

// MARK: Statement Visitors
extension Interpreter: StmtVisitor {
    public func visitBlockStmt(_ stmt: Block) -> Any? {
        executeBlock(stmts: stmt.statements, environ: Environment(enclosing: self.environment))
        return nil
    }
    
    public func visitExpressionStmt(_ stmt: Expression) -> Any? {
        _ = evaluate(stmt.expression)
        return nil
    }
    
    public func visitPrintStmt(_ stmt: Print) -> Any? {
        let val = evaluate(stmt.expression)
        print(stringify(val))
        return nil
    }
    
    public func visitVarStmt(_ stmt: Var) -> Any? {
        var val: Any? = nil
        if let initalizer = stmt.initializer {
            val = evaluate(initalizer)
        }
        
        environment.define(name: stmt.name.lexeme, value: val)
        return nil
    }
    
    
}
