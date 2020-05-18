//
//  Expr.swift
//  
//
//  Created by Kevin Turner on 5/16/20.
//

import Foundation


public protocol Visitor: class {
    associatedtype R
//    func visitAssignExpr(expr: Assign) -> R
    func visitBinaryExpr(expr: Binary) -> R
//    func visitCallExpr(expr: Call) -> R
    func visitGroupingExpr(expr: Grouping) -> R
    func visitLiteralExpr(expr: Literal) -> R
//    func visitLogicalExpr(expr: Logical) -> R
    func visitUnaryExpr(expr: Unary) -> R
}

public protocol Expr {
    func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor
}


//public struct Assign: Expr {
//    let name: Token
//    let value: Expr
//
//    public func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
//        return visitor.visitAssignExpr(expr: self) as! R
//    }
//}


public struct Binary: Expr {
    let left: Expr
    let op: Token
    let right: Expr
    
    public func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
        return visitor.visitBinaryExpr(expr: self) as! R
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
    
    public func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
        return visitor.visitGroupingExpr(expr: self) as! R
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
    
    
    
    public func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
        return visitor.visitLiteralExpr(expr: self) as! R
    }
}

//public struct Logical: Expr {
//    let left: Expr
//    let op: Token
//    let right: Expr
//    
//    public func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
//        return visitor.visitLogicalExpr(expr: self) as! R
//    }
//}

public struct Unary: Expr {
    let op: Token
    let right: Expr
    
    public func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
        return visitor.visitUnaryExpr(expr: self) as! R
    }
}
