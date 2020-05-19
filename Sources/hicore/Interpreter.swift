//
//  Interpreter.swift
//  
//
//  Created by Kevin Turner on 5/18/20.
//

import Foundation

public class Interpreter: Visitor {
    
    public init() {}
    
    public func interpret(expr: Expr) -> Swift.Result<(), Error> {
        let value = evaluate(expr)
        print(stringify(value))
        return .success(())
    }
    
    private func stringify(_ obj: Any?) -> String {
        guard let nonNilObj = obj else { return "nada" }
        
        if nonNilObj is Double {
            return String(nonNilObj as! Double)
        }
        
        fatalError("unexpected type in stringify")
    }
    
    public func visitBinaryExpr(expr: Binary) -> Any? {
        let left = evaluate(expr.left)
        let right = evaluate(expr.right)
        
        switch expr.op.tokenType { // TODO: error check casts to Double, take care of PLUS operator (strings and double types)
        case .MINUS:
            return (left as! Double) - (right as! Double)
        case .SLASH:
            return (left as! Double) / (right as! Double)
        case .STAR:
            return (left as! Double) * (right as! Double)
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
        case .PLUS:
            return (left as! Double) + (right as! Double)
        default:
            print("Invalid operator for Binary expression")
            return nil
        }
    }
    
    public func visitGroupingExpr(expr: Grouping) -> Any? {
        return evaluate(expr.expression)
    }
    
    public func visitLiteralExpr(expr: Literal) -> Any? {
        return expr.value // TODO: unwrap gracefully
    }
    
    
    public func visitUnaryExpr(expr: Unary) -> Any? {
        let right = evaluate(expr.right)
        
        switch expr.op.tokenType {
        case .MINUS:
            return -(right as! Double)
        case .BANG:
            return !isTruthy(right)
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
