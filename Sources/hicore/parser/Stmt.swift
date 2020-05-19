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
    func visitIfStmt(_ stmt: If) throws -> R
    func visitWhileStmt(_ stmt: While) throws -> R
}

public protocol Stmt {
    func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor
}

public struct Block: Stmt {
    let statements: Array<Stmt>
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitBlockStmt(self) as! R
    }
}

public struct If: Stmt {
    let condition: Expr
    let thenBranch: Stmt
    let elseBranch: Stmt?
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitIfStmt(self) as! R
    }
}

public struct Expression: Stmt {
    let expression: Expr
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitExpressionStmt(self) as! R
    }
}

public struct Print: Stmt {
    let expression: Expr
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitPrintStmt(self) as! R
    }
}

public struct Var: Stmt {
    let name: Token
    let initializer: Expr?
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitVarStmt(self) as! R
    }
}

public struct While: Stmt {
    let condition: Expr
    let body: Stmt
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : StmtVisitor {
        return try visitor.visitWhileStmt(self) as! R
    }
}
