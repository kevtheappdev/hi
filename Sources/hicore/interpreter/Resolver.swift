//
//  Resolver.swift
//  
//
//  Created by Kevin Turner on 5/21/20.
//

import Foundation

class Resolver: ExprVisitor, StmtVisitor {

    

    
    
    private let interpreter: Interpreter
    private final var scopes = Array<Dictionary<String, Bool>>()
    private var currentFunction = FunctionType.NONE
    private var currentClass = ClassType.NONE
    
    init(interpreter: Interpreter) {
        self.interpreter = interpreter
    }
    

    func resolve(All stmts: Array<Stmt>) -> Result<Array<Stmt>, Error> {
        do {
            try resolve(stmts: stmts)
        } catch {
            return .failure(error)
        }
        
        return .success(stmts)
    }
    
    func visitSuperExpr(expr: Super) throws -> Any? {
        // TODO: fix this.. obviously
        if currentClass == .NONE {
            print("Can't use super outside of a class.")
        } else if currentClass != .SUBCLASS{
            print("Can't use super in a class with no superclass.")
        }
        
        resolveLocal(expr: expr, name: expr.kwd)
        return nil
    }
    
    func visitSetExpr(expr: Set) throws -> Any? {
        try resolve(expr: expr.value)
        try resolve(expr: expr.obj)
        return nil
    }
    
    func visitSelfExpr(expr: HiSelf) throws -> Any? {
        if currentClass == .NONE {
            print("Cannot use 'this' outside of a class.") // TODO: make real error
        }
        resolveLocal(expr: expr, name: expr.kwd)
        return nil
    }

    func visitAssignExpr(expr: Assign) throws -> Any? {
        try resolve(expr: expr.value)
        resolveLocal(expr: expr, name: expr.name)
        return nil
    }
    
    func visitGetExpr(expr: Get) throws -> Any? {
        try resolve(expr: expr.obj)
        return nil
    }
    
    
    func visitBinaryExpr(expr: Binary) throws -> Any? {
        try resolve(expr: expr.left)
        try resolve(expr: expr.right)
        return nil
    }
    
    func visitCallExpr(expr: Call) throws -> Any? {
        try resolve(expr: expr.callee)
        
        for arg in expr.arguments {
            try resolve(expr: arg)
        }
        
        return nil
    }
    
    func visitGroupingExpr(expr: Grouping) throws -> Any? {
        try resolve(expr: expr.expression)
        return nil
    }
    
    func visitLiteralExpr(expr: Literal) throws -> Any? {
        if let litArray = expr.value as? Array<Expr> {
            for val in litArray {
                try resolve(expr: val)
            }
        }
        return nil
    }
    
    func visitLogicalExpr(expr: Logical) throws -> Any? {
        try resolve(expr: expr.right)
        try resolve(expr: expr.left)
        return nil
    }
    
    func visitUnaryExpr(expr: Unary) throws -> Any? {
        try resolve(expr: expr.right)
        return nil
    }
    
    func visitVariableExpr(expr: Variable) throws -> Any? {
        if !scopes.isEmpty && scopes.last?[expr.name.lexeme] == false {
            print("Error: cannot read local variable in own initializer") // TODO: pipe error correctly
        }
        
        resolveLocal(expr: expr, name: expr.name)
        return nil
    }
    
    func visitBlockStmt(_ stmt: Block) throws -> Any? {
        beginScope()
        try resolve(stmts: stmt.statements)
        endScope()
        return nil
    }
    
    func visitExpressionStmt(_ stmt: Expression) throws -> Any? {
        _ = try resolve(expr: stmt.expression)
        return nil
    }
    
    func visitPrintStmt(_ stmt: Print) throws -> Any? {
        try resolve(expr: stmt.expression)
        return nil
    }
    
    func visitVarStmt(_ stmt: Var) throws -> Any? {
        declare(name: stmt.name)
        if let initiazlier = stmt.initializer {
            try _ =  resolve(expr: initiazlier)
        }
        define(name: stmt.name)
        return nil
    }
    
    func visitFunctionStmt(_ stmt: Function) throws -> Any? {
        declare(name: stmt.name)
        define(name: stmt.name)
        
        try resolveFunction(fun: stmt, type: .FUNCTION)
        return nil
    }
    
    func visitReturnStmt(_ stmt: Return) throws -> Any? {
        if currentFunction == .NONE {
            print("Error: Cannot return from top-level code") // TODO: amend with improved error handling
        }
        
        if let rtrnVal = stmt.value {
            if currentFunction == .INITIALIZER {
                 print("ERROR: cannot return a value from an initializer") // TODO: amend with improved error handling
            }
            _ = try resolve(expr: rtrnVal)
        }
        return nil
    }
    
    func visitIfStmt(_ stmt: If) throws -> Any? {
        try resolve(expr: stmt.condition)
        try resolve(stmt: stmt.thenBranch)
        if let elseBranch = stmt.elseBranch {
            try resolve(stmt: elseBranch)
        }
        return nil
    }
    
    func visitWhileStmt(_ stmt: While) throws -> Any? {
        try resolve(expr: stmt.condition)
        try resolve(stmt: stmt.body)
        return nil
    }
    
    func visitClassStmt(_ stmt: Class) throws -> Any? {
        let enclosingClass = currentClass
        currentClass = .CLASS
        
        declare(name: stmt.name)
        define(name: stmt.name)
        
        var hasSuperClass = false
        if let superclass = stmt.superclass {
            if superclass.name.lexeme == stmt.name.lexeme {
                print("Error: A class cannot inherit from itself") // TODO: FIXME!!
            }
            try resolve(expr: superclass)
            hasSuperClass = true
            currentClass = .SUBCLASS
        }
        
        if hasSuperClass {
            beginScope()
            var scope = scopes.popLast()!
            scope["super"] = true
            scopes.append(scope)
        }
        
        beginScope()
        var lastScope = scopes.popLast()!
        lastScope["self"] = true
        scopes.append(lastScope)
        
        for method in stmt.methods {
            var decl = FunctionType.METHOD
            if method.name.lexeme == "init" {
                decl = .INITIALIZER
            }
            try resolveFunction(fun: method, type: decl)
        }
        
        endScope()
        if hasSuperClass { endScope() }
        
        currentClass = enclosingClass
        return nil
    }
    
    
    func resolve(stmts: Array<Stmt>) throws {
        for stmt in stmts {
            try resolve(stmt: stmt)
        }
    }
    
    func resolve(stmt: Stmt) throws {
        let _: Any? = try stmt.acceptVisitor(visitor: self)
    }
    
    private func resolveFunction(fun: Function, type: FunctionType) throws {
        let enclosingFunc = currentFunction
        currentFunction = type
        
        beginScope()
        for param in fun.params {
            declare(name: param)
            define(name: param)
        }
        
        try resolve(stmts: fun.body)
        endScope()
        currentFunction = enclosingFunc
    }
    
    private func resolve(expr: Expr) throws {
        let _: Any? = try expr.acceptVisitor(visitor: self)
    }
    
    private func resolveLocal(expr: Expr, name: Token) {
        for i in (0..<scopes.count).reversed() {
            let scope = scopes[i]
            if scope.keys.contains(name.lexeme) {
                // call resolve on interpreter
                interpreter.resolve(expr: expr, depth: scopes.count - 1 - i)
                return
            }
        }
        
        // assume global
    }
    
    private func declare(name: Token) {
        if scopes.isEmpty { return }
        
        var scope = scopes.popLast()!
        if scope.keys.contains(name.lexeme) {
            print("Error: Variable with this name already declare din this scope.") // TODO: update with error handling
        }
        
        scope[name.lexeme] = false
        scopes.append(scope)
    }
    
    private func define(name: Token) {
        if scopes.isEmpty { return }
        var scope = scopes.popLast()!
        scope[name.lexeme] = true
        scopes.append(scope)
    }
    
    private func beginScope() {
        scopes.append(Dictionary<String, Bool>())
    }
    
    private func endScope() {
        _ = scopes.popLast()
    }
    
    typealias R = Any?
    
    
}


private enum FunctionType {
    case NONE
    case FUNCTION
    case METHOD
    case INITIALIZER
}

private enum ClassType {
    case NONE
    case CLASS
    case SUBCLASS
}
