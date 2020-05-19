//
//  Expr.swift
//  
//
//  Created by Kevin Turner on 5/16/20.
//

import Foundation


public protocol ExprVisitor: class {
    associatedtype R
    func visitAssignExpr(expr: Assign) throws -> R
    func visitBinaryExpr(expr: Binary) throws -> R
//    func visitCallExpr(expr: Call) -> R
    func visitGroupingExpr(expr: Grouping) throws -> R
    func visitLiteralExpr(expr: Literal) throws -> R
    func visitLogicalExpr(expr: Logical) throws -> R
    func visitUnaryExpr(expr: Unary) throws -> R
    func visitVariableExpr(expr: Variable) throws -> R
}

public protocol Expr {
    func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor
}


public struct Assign: Expr {
    let name: Token
    let value: Expr

    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitAssignExpr(expr: self) as! R
    }
}


public struct Binary: Expr {
    let left: Expr
    let op: Token
    let right: Expr
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitBinaryExpr(expr: self) as! R
    }
}

//
//public struct Call: Expr {
//    let callee: Expr
//    let paren: Token
//    let arguments: Array<Expr>
//
//    public func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
//        return visitor.visitCallExpr(expr: self) as! R
//    }
//}

public struct Grouping: Expr {
    let expression: Expr
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitGroupingExpr(expr: self) as! R
    }
}

public struct Literal: Expr, CustomDebugStringConvertible {
    public var debugDescription: String {
        get {
            if value is String {
                return value as! String
            } else if value is Float {
                return String(value as! Float)
            } else if value is Int {
                return String(value as! Int)
            } else {
                fatalError("Invalid Literal") // TODO: probably an overreaction
            }
        }
    }
    
    let value: Any?
    
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitLiteralExpr(expr: self) as! R
    }
}

public struct Logical: Expr {
    let left: Expr
    let op: Token
    let right: Expr
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitLogicalExpr(expr: self) as! R
    }
}

public struct Unary: Expr {
    let op: Token
    let right: Expr
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitUnaryExpr(expr: self) as! R
    }
}

public struct Variable: Expr {
    let name: Token
    
    public func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitVariableExpr(expr: self) as! R
    }
}
