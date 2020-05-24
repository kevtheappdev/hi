//
//  Interpreter.swift
//  
//
//  Created by Kevin Turner on 5/18/20.
//

import Foundation

public class Interpreter {
    let globals = Environment()
    private var environment: Environment
    private var locals = Dictionary<Expr, Int>()
    
    public init() {
        environment = globals
        
        // init stdlib
        globals.define(name: "clock", value: Clock())
        globals.define(name: "sin", value: Sin())
        globals.define(name: "cos", value: Cos())
        globals.define(name: "tan", value: Tan())
        globals.define(name: "round", value: Round())
        
        // constants
        globals.define(name: "PI", value: Double.pi)
    }
    
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
    
    internal func executeBlock(stmts: Array<Stmt>, environ: Environment) throws {
        let prev = self.environment
        defer {
            self.environment = prev
        }
        
        self.environment = environ
        
        for stmt in stmts {
             try execute(stmt: stmt)
        }
    }
    
    func resolve(expr: Expr, depth: Int) {
        locals[expr] = depth
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
        
        if let stringConvertible = nonNilObj as? CustomStringConvertible {
            return stringConvertible.description
        }
        
        fatalError("Object could not be stringified")
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
    public func visitSelfExpr(expr: HiSelf) throws -> Any? {
        return try lookUpVariable(name: expr.kwd, expr: expr)
    }
    
    public func visitSetExpr(expr: Set) throws -> Any? {
        let obj = try evaluate(expr.obj)
        
        if !(obj is HiInstance) {
            throw RuntimeError(tok: expr.name, message: "Only instances have fields.")
        }
        
        let val = try evaluate(expr.value)
        (obj as! HiInstance).set(name: expr.name, val: val)
        return val
    }
    
    public func visitGetExpr(expr: Get) throws -> Any? {
        let obj = try evaluate(expr.obj)
        if let hiInstance = obj as? HiInstance {
            return try hiInstance.get(index: expr.name)
        }
        
        return nil
    }
    
    public func visitCallExpr(expr: Call) throws -> Any? {
        let callee = try evaluate(expr.callee)
        
        if !(callee is HiCallable) {
            throw RuntimeError(tok: expr.paren, message: "Uncallable type")
        }
        
        var args = Array<Any?>()
        for arg in expr.arguments {
            args.append(try evaluate(arg))
        }
        
        let callable = callee as! HiCallable
        if callable.arity() != args.count {
            throw RuntimeError(tok: expr.paren, message: "Expected \(callable.arity()) arguments but got \(args.count)")
        }
        
        return try callable.call(self, args: args)
    }
    
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
        
        if let distance = locals[expr] {
            try environment.assign(AtDistance: distance, name: expr.name, value: val)
        } else {
            try globals.assign(name: expr.name, value: expr.value)
        }
    
        return val
    }
    
    public func visitVariableExpr(expr: Variable) throws -> Any? {
        return try lookUpVariable(name: expr.name, expr: expr)
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
            return !isEqual(lNum, b: rNum)
        case .EQUAL_EQUAL:
            return isEqual(lNum, b: rNum)
        case .PLUS:
            return lNum + rNum
        default:
            throw RuntimeError(tok: expr.op, message: "Invalid operands for binary expression")
        }
    }
    
    private func lookUpVariable(name: Token, expr: Expr) throws -> Any? {
        if let distance = locals[expr] {
            return try environment.get(AtDistance: distance, name: name.lexeme)
        } else {
            return try globals.get(name: name)
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
    public func visitClassStmt(_ stmt: Class) throws -> Any? {
        environment.define(name: stmt.name.lexeme, value: nil)

        
        var methods = Dictionary<String, HiFunction>()
        for method in stmt.methods {
            let hiFunc = HiFunction(declaration: method, closure: environment, isInitializer: method.name.lexeme == "init")
            methods[method.name.lexeme] = hiFunc
        }
        let hiClass = HiClass(name: stmt.name.lexeme, methods: methods)
        try environment.assign(name: stmt.name, value: hiClass)
        
        return nil
    }
    
    public func visitReturnStmt(_ stmt: Return) throws -> Any? {
        var val: Any? = nil
        if let returnVal = stmt.value {
            val = try evaluate(returnVal)
        }
        
        throw ReturnExcept(val: val)
    }
    
    public func visitFunctionStmt(_ stmt: Function) throws -> Any? {
        let fun = HiFunction(declaration: stmt, closure: environment)
        environment.define(name: stmt.name.lexeme, value: fun)
        return nil
    }
    
    public func visitWhileStmt(_ stmt: While) throws -> Any? {
        while isTruthy(try evaluate(stmt.condition)) {
            try execute(stmt: stmt.body)
        }
        return nil
    }
    
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
