//
//  ASTPrinter.swift
//  
//
//  Created by Kevin Turner on 5/17/20.
//

import Foundation


public class AstPrinter: Visitor {
    public init() {}
    
//    public func visitAssignExpr(expr: Assign) -> String {
//        return parenthesize(name: expr.name.lexeme, expr.value)
//    }
    
    public func visitBinaryExpr(expr: Binary) -> String {
        return parenthesize(name: expr.op.lexeme, expr.left, expr.right)
    }
    
//    public func visitCallExpr(expr: Call) -> String {
//        return parenthesize(name: "calling", expr) // TODO: wrong
//    }
    
    public func visitGroupingExpr(expr: Grouping) -> String {
        return parenthesize(name: "group", expr.expression)
    }
    
    public func visitLiteralExpr(expr: Literal) -> String {
        if expr.value == nil { return "nada" }
        return expr.debugDescription
    }
    
//    public func visitLogicalExpr(expr: Logical) -> String {
//        return expr.op.lexeme // TODO: fix
//    }
    
    public func visitUnaryExpr(expr: Unary) -> String {
        return parenthesize(name: expr.op.lexeme, expr.right)
    }
    
    public typealias R = String

    public func print(_ expr: Expr) -> String {
        return expr.acceptVisitor(visitor: self)
    }
    
    private func parenthesize(name: String, _ exprs: Expr...) -> String {
        var result = "(\(name)"
        
        for expr in exprs {
            result += expr.acceptVisitor(visitor: self)
        }
        result += ")"
        
        return result
    }
    
    
}
