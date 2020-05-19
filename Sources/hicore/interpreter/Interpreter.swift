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
        do {
            for statement in statements {
                try execute(stmt: statement)
            }
        } catch {
            return .failure(error)
        }
        
        return .success(())
    }
    
    private func execute(stmt: Stmt) throws {
        _ = try stmt.acceptVisitor(visitor: self) as Any
    }
    
    private func executeBlock(stmts: Array<Stmt>, environ: Environment) throws {
        let prev = self.environment
        defer {
            self.environment = prev
        }
        
        self.environment = environ
        
        for stmt in stmts {
             try execute(stmt: stmt)
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
    
    private func evaluate(_ expr: Expr) throws -> Any? {
        return try expr.acceptVisitor(visitor: self)
    }
    
    public typealias R = Any?
    
}

// MARK: Expression Visitors
extension Interpreter: ExprVisitor {
    public func visitLogicalExpr(expr: Logical) throws -> Any? {
        let left = try evaluate(expr.left)
        
        // short circuit if possible
        if expr.op.tokenType == .OR {
            if isTruthy(left) { return left }
        } else {
            if !isTruthy(left) { return left }
        }
        
        return try evaluate(expr.right)
    }
    
    public func visitAssignExpr(expr: Assign) throws -> Any? {
        let val = try evaluate(expr.value)
        
        try environment.assign(name: expr.name, value: val)
        return val
    }
    
    public func visitVariableExpr(expr: Variable) throws -> Any? {
        return try environment.get(name: expr.name)
    }
    
    public func visitBinaryExpr(expr: Binary) throws -> Any? {
        let left = try evaluate(expr.left)
        let right = try evaluate(expr.right)
        
        // string concatenation
        if expr.op.tokenType == .PLUS && left is String && right is String {
            return (left as! String) + (right as! String)
        }
        
        // operations on numbers
        let (lNum, rNum) = try! operandsNumberValue(op: expr.op, left: left, right: right)
        switch expr.op.tokenType { // TODO: error check casts to Double, take care of PLUS operator (strings and double types)
        case .MINUS:
            return lNum - rNum
        case .SLASH:
            return lNum / rNum
        case .STAR:
            return lNum * rNum
        case .GREATER:
            return lNum > rNum
        case .GREATER_EQUALS:
            return lNum >= rNum
        case .LESS:
            return lNum < rNum
        case .LESS_EQUALS:
            return lNum <= rNum
        case .BANG:
            return isEqual(lNum, b: rNum)
        case .PLUS:
            return lNum + rNum
        default:
            throw RuntimeError(tok: expr.op, message: "Invalid operands for binary expression")
        }
    }
    
    private func operandNumberValue(op: Token, operand: Any?) throws -> Double {
        if operand is Double { return operand as! Double }
        if operand == nil { throw RuntimeError(tok: op, message: "Operand is nada!.") }
        throw RuntimeError(tok: op, message: "Operand must be a number.")
    }
    
    private func operandsNumberValue(op: Token, left: Any?, right: Any?) throws -> (Double, Double)  {
        if left is Double && right is Double { return (left as! Double, right as! Double)}
        if left == nil || right == nil { throw RuntimeError(tok: op, message: "Operand cannot be nada in binary expression!") }
        throw RuntimeError(tok: op, message: "Operands must be numbers")
    }
    
    public func visitGroupingExpr(expr: Grouping) throws -> Any? {
        return try evaluate(expr.expression)
    }
    
    public func visitLiteralExpr(expr: Literal) throws -> Any? {
        return expr.value // TODO: unwrap gracefully
    }
    
    public func visitUnaryExpr(expr: Unary) throws -> Any? {
        let right = try evaluate(expr.right)
        
        switch expr.op.tokenType {
        case .MINUS:
            let num = try! operandNumberValue(op: expr.op, operand: right) // TODO: make visitor interface allow for throwing errors
            return -(num)
        case .BANG:
            return !isTruthy(right)
        default:
            throw RuntimeError(tok: expr.op, message: "Invalid Unary Operand.")
        }
    }

}

// MARK: Statement Visitors
extension Interpreter: StmtVisitor {
    public func visitIfStmt(_ stmt: If) throws -> Any? {
        if isTruthy(try evaluate(stmt.condition)) {
            try execute(stmt: stmt.thenBranch)
        } else if let elseBranch = stmt.elseBranch {
            try execute(stmt: elseBranch)
        }
        
        return nil
    }
    
    public func visitBlockStmt(_ stmt: Block) throws -> Any? {
        try executeBlock(stmts: stmt.statements, environ: Environment(enclosing: self.environment))
        return nil
    }
    
    public func visitExpressionStmt(_ stmt: Expression) throws -> Any? {
        _ = try evaluate(stmt.expression)
        return nil
    }
    
    public func visitPrintStmt(_ stmt: Print) throws -> Any? {
        let val = try evaluate(stmt.expression)
        print(stringify(val))
        return nil
    }
    
    public func visitVarStmt(_ stmt: Var) throws -> Any? {
        var val: Any? = nil
        if let initalizer = stmt.initializer {
            val = try evaluate(initalizer)
        }
        
        environment.define(name: stmt.name.lexeme, value: val)
        return nil
    }
    
    
}
