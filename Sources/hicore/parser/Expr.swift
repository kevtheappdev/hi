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
    func visitCallExpr(expr: Call) throws -> R
    func visitGroupingExpr(expr: Grouping) throws -> R
    func visitLiteralExpr(expr: Literal) throws -> R
    func visitLogicalExpr(expr: Logical) throws -> R
    func visitUnaryExpr(expr: Unary) throws -> R
    func visitVariableExpr(expr: Variable) throws -> R
    func visitGetExpr(expr: Get) throws -> R
    func visitSetExpr(expr: Set) throws -> R
    func visitSelfExpr(expr: HiSelf) throws -> R
    func visitSuperExpr(expr: Super) throws -> R
}

public class Expr: Hashable {
    func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        fatalError("Not implemented")
    }
    
    public static func == (lhs: Expr, rhs: Expr) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}


public class Assign: Expr {
    let name: Token
    let value: Expr

    init(name: Token, value: Expr) {
        self.name = name
        self.value = value
    }

    
    public override func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitAssignExpr(expr: self) as! R
    }
}


public class Binary: Expr {
    let left: Expr
    let op: Token
    let right: Expr
    
    init(left: Expr, op: Token, right: Expr) {
        self.left = left
        self.op = op
        self.right = right
    }
    
    public override func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitBinaryExpr(expr: self) as! R
    }
}


public class Call: Expr {
    let callee: Expr
    let paren: Token
    let arguments: Array<Expr>
    
    init(callee: Expr, paren: Token, arguments: Array<Expr>) {
        self.callee = callee
        self.paren = paren
        self.arguments = arguments
    }

    public override func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitCallExpr(expr: self) as! R
    }
}

public class Grouping: Expr {
    let expression: Expr
    
    init(expression: Expr) {
        self.expression = expression
    }
    
    public override func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitGroupingExpr(expr: self) as! R
    }
}

public class Literal: Expr, CustomDebugStringConvertible {
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
    
    init(value: Any?) {
        self.value = value
    }
    
    
    public override func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitLiteralExpr(expr: self) as! R
    }
}

public class Logical: Expr {
    let left: Expr
    let op: Token
    let right: Expr
    
    init(left: Expr, op: Token, right: Expr) {
        self.left = left
        self.op = op
        self.right = right
    }
    
    public override func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitLogicalExpr(expr: self) as! R
    }
}

public class Unary: Expr {
    let op: Token
    let right: Expr
    
    init(op: Token, right: Expr) {
        self.op = op
        self.right = right
    }
    
    public override func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitUnaryExpr(expr: self) as! R
    }
}

public class Variable: Expr {
    let name: Token
    
    init(name: Token) {
        self.name = name
    }
    
    public override func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitVariableExpr(expr: self) as! R
    }
}

public class Get: Expr {
    let obj: Expr
    let name: Token
    
    init(obj: Expr, name: Token) {
        self.obj = obj
        self.name = name
    }
    
    public override func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitGetExpr(expr: self) as! R
    }
}

public class Set: Expr {
    let obj: Expr
    let name: Token
    let value: Expr
    
    init(obj: Expr, name: Token, value: Expr) {
        self.obj = obj
        self.name = name
        self.value = value
    }
    
    override func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitSetExpr(expr: self) as! R
    }
}


public class HiSelf: Expr {
    let kwd: Token
    
    init(kwd: Token) {
        self.kwd = kwd
    }
    
    override func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitSelfExpr(expr: self) as! R
    }
}


public class Super: Expr {
    let kwd: Token
    let method: Token
    
    init(kwd: Token, method: Token) {
        self.kwd = kwd
        self.method = method
    }
    
    override func acceptVisitor<T, R>(visitor: T) throws -> R where T : ExprVisitor {
        return try visitor.visitSuperExpr(expr: self) as! R
    }
}
