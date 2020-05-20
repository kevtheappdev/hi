//
//  Stmt.swift
//  
//
//  Created by Kevin Turner on 5/18/20.
//

import Foundation

public protocol StmtVisitor: class {
    associatedtype R
    func visitBlockStmt(_ stmt: Block) throws -> R
    func visitExpressionStmt(_ stmt: Expression) throws -> R
    func visitPrintStmt(_ stmt: Print) throws -> R
    func visitVarStmt(_ stmt: Var) throws -> R
    func visitFunctionStmt(_ stmt: Function) throws -> R
    func visitReturnStmt(_ stmt: Return) throws -> R
    func visitIfStmt(_ stmt: If) throws -> R
    func visitWhileStmt(_ stmt: While) throws -> R
}

public protocol Stmt {
    func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor
}

public class Block: Stmt {
    let statements: Array<Stmt>
    
    init(statements: Array<Stmt>) {
        self.statements = statements
    }
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitBlockStmt(self) as! R
    }
}

public class If: Stmt {
    let condition: Expr
    let thenBranch: Stmt
    let elseBranch: Stmt?
    
    init(condition: Expr, thenBranch: Stmt, elseBranch: Stmt?) {
        self.condition = condition
        self.thenBranch = thenBranch
        self.elseBranch = elseBranch
    }
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitIfStmt(self) as! R
    }
}

public class Expression: Stmt {
    let expression: Expr
    
    init(expression: Expr) {
        self.expression = expression
    }
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitExpressionStmt(self) as! R
    }
}

public class Print: Stmt {
    let expression: Expr
    
    init(expression: Expr) {
        self.expression = expression
    }
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitPrintStmt(self) as! R
    }
}

public class Function: Stmt {
    let name: Token
    let params: Array<Token>
    let body: Array<Stmt>
    
    init(name: Token, params: Array<Token>, body: Array<Stmt>) {
        self.name = name
        self.params = params
        self.body = body
    }
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitFunctionStmt(self) as! R
    }
}

public class Return: Stmt {
    let kwd: Token
    let value: Expr?
    
    init(kwd: Token, value: Expr?) {
        self.kwd = kwd
        self.value = value
    }
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitReturnStmt(self) as! R
    }
}

public class Var: Stmt {
    let name: Token
    let initializer: Expr?
    
    init(name: Token, initializer: Expr?) {
        self.name = name
        self.initializer = initializer
    }
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitVarStmt(self) as! R
    }
}

public class While: Stmt {
    let condition: Expr
    let body: Stmt
    
    init(condition: Expr, body: Stmt) {
        self.condition = condition
        self.body = body
    }
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitWhileStmt(self) as! R
    }
}
