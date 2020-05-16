//
//  Expr.swift
//  
//
//  Created by Kevin Turner on 5/16/20.
//

import Foundation


protocol Visitor: class {
    func visitAssignExpr<R>(expr: Assign) -> R
    func visitBinaryExpr<R>(expr: Binary) -> R
    func visitCallExpr<R>(expr: Call) -> R
    func visitGroupingExpr<R>(expr: Grouping) -> R
    func visitLiteralExpr<R>(expr: Literal) -> R
    func visitLogicalExpr<R>(expr: Logical) -> R
    func visitUnaryExpr<R>(expr: Unary) -> R
}

protocol Expr {
    func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor
}


struct Assign: Expr {
    let name: Token
    let value: Expr
    
    func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
        return visitor.visitAssignExpr(expr: self)
    }
}


struct Binary: Expr {
    let left: Expr
    let op: Token
    let right: Expr
    
    func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
        return visitor.visitBinaryExpr(expr: self)
    }
}


struct Call: Expr {
    let callee: Expr
    let paren: Token
    let arguments: Array<Expr>
    
    func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
        return visitor.visitCallExpr(expr: self)
    }
}

struct Grouping: Expr {
    let expression: Expr
    
    func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
        return visitor.visitGroupingExpr(expr: self)
    }
}

struct Literal: Expr {
    let value: AnyObject
    
    func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
        return visitor.visitLiteralExpr(expr: self)
    }
}

struct Logical: Expr {
    let left: Expr
    let op: Token
    let right: Expr
    
    func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
        return visitor.visitLogicalExpr(expr: self)
    }
}

struct Unary: Expr {
    let op: Token
    let right: Expr
    
    func acceptVisitor<T, R>(visitor: T) -> R where T : Visitor {
        return visitor.visitUnaryExpr(expr: self)
    }
}
