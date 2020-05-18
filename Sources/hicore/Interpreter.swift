//
//  File.swift
//  
//
//  Created by Kevin Turner on 5/18/20.
//

import Foundation

public class Interpreter: Visitor {
    
    public init() {}
    
    public func interpret(expr: Expr) {
        let value = evaluate(expr)
        print(stringify(value))
    }
    
    private func stringify(_ obj: Any?) -> String {
        guard let nonNilObj = obj else { return "nada" }
        
        if nonNilObj is Double {
            return String(nonNilObj as! Double)
        }
        
        fatalError("da fuck is this")
    }
    
    public func visitBinaryExpr(expr: Binary) -> Any? {
        let left = evaluate(expr.left)
        let right = evaluate(expr.right)
        // TODO: check above for nil
        
        
        switch expr.op.tokenType { // TODO: error check casts to Double, take care of PLUS operator (strings and double types)
        case .MINUS:
            return (left as! Double) - (right as! Double) as Any
        case .SLASH:
            return (left as! Double) / (right as! Double) as Any
        case .STAR:
            return (left as! Double) * (right as! Double) as Any
        case .GREATER:
            return (left as! Double) > (right as! Double)
        case .GREATER_EQUALS:
            return (left as! Double) >= (right as! Double)
        case .LESS:
            return (left as! Double) < (right as! Double)
        case .LESS_EQUALS:
            return (left as! Double) <= (right as! Double)
        case .BANG:
            return isEqual((left as! Double), b: (right as! Double))
        default:
            fatalError("Invalid operator for Binary expression")
        }
    }
    
    public func visitGroupingExpr(expr: Grouping) -> Any? {
        return evaluate(expr)
    }
    
    public func visitLiteralExpr(expr: Literal) -> Any? {
        return expr.value // TODO: unwrap gracefully
    }
    
    
    public func visitUnaryExpr(expr: Unary) -> Any? {
        let right = evaluate(expr.right)
        
        switch expr.op.tokenType {
        case .MINUS:
            return -(right as! Double) as Any
        case .BANG:
            return !isTruthy(right) as Any
        default:
            fatalError("Invalid Unary operator")
        }
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
    
    private func evaluate(_ expr: Expr) -> Any? {
        return expr.acceptVisitor(visitor: self)
    }
    
    public typealias R = Any?
    
    
}
