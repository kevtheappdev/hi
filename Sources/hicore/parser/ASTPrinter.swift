//
//  ASTPrinter.swift
//  
//
//  Created by Kevin Turner on 5/17/20.
//

import Foundation


public class AstPrinter: ExprVisitor {
    public func visitCallExpr(expr: Call) throws -> String {
        return ""
    }
    
    public func visitLogicalExpr(expr: Logical) throws -> String {
        return ""
    }
    
    public func visitAssignExpr(expr: Assign) -> String {
        return ""
    }
    
    public func visitVariableExpr(expr: Variable) -> String {
        return "" // TODO: revisit
    }
    
    public init() {}
    
//    public func visitAssignExpr(expr: Assign) -> String {
//        return parenthesize(name: expr.name.lexeme, expr.value)
//    }
    
    public func visitBinaryExpr(expr: Binary) throws -> String {
        return try parenthesize(name: expr.op.lexeme, expr.left, expr.right)
    }
    
//    public func visitCallExpr(expr: Call) -> String {
//        return parenthesize(name: "calling", expr) // TODO: wrong
//    }
    
    public func visitGroupingExpr(expr: Grouping) throws -> String {
        return try parenthesize(name: "group", expr.expression)
    }
    
    public func visitLiteralExpr(expr: Literal) -> String {
        if expr.value == nil { return "nada" }
        return expr.debugDescription
    }
    
    public func visitUnaryExpr(expr: Unary) throws -> String {
        return try parenthesize(name: expr.op.lexeme, expr.right)
    }
    
    public typealias R = String

    public func print(_ expr: Expr) throws -> String {
        return try expr.acceptVisitor(visitor: self)
    }
    
    private func parenthesize(name: String, _ exprs: Expr...) throws -> String {
        var result = "(\(name)"
        
        for expr in exprs {
            result += try expr.acceptVisitor(visitor: self)
        }
        result += ")"
        
        return result
    }
    
    
}
