//
//  Stmt.swift
//  
//
//  Created by Kevin Turner on 5/18/20.
//

import Foundation

public protocol StmtVisitor: class {
    associatedtype R
    func visitBlockStmt(_ stmt: Block) -> R
    func visitExpressionStmt(_ stmt: Expression) -> R
    func visitPrintStmt(_ stmt: Print) -> R
    func visitVarStmt(_ stmt: Var) -> R
}

public protocol Stmt {
    func acceptVisitor<T, R>(visitor: T) -> R where T : StmtVisitor
}

public struct Block: Stmt {
    let statements: Array<Stmt>
    
    public func acceptVisitor<T, R>(visitor: T) -> R where T : StmtVisitor {
        return visitor.visitBlockStmt(self) as! R
    }
}

public struct Expression: Stmt {
    let expression: Expr
    
    public func acceptVisitor<T, R>(visitor: T) -> R where T : StmtVisitor {
        return visitor.visitExpressionStmt(self) as! R
    }
}

public struct Print: Stmt {
    let expression: Expr
    
    public func acceptVisitor<T, R>(visitor: T) -> R where T : StmtVisitor {
        return visitor.visitPrintStmt(self) as! R
    }
}

public struct Var: Stmt {
    let name: Token
    let initializer: Expr?
    
    public func acceptVisitor<T, R>(visitor: T) -> R where T : StmtVisitor {
        return visitor.visitVarStmt(self) as! R
    }
}
