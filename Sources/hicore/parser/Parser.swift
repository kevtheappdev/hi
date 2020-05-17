//
//  Parser.swift
//  
//
//  Created by Kevin Turner on 5/17/20.
//

import Foundation

public class Parser {
    private let tokens: Array<Token>
    private var current = 0
    
    public init(withTokens tokens: Array<Token>) {
        self.tokens = tokens
    }
    
    public func parse() -> Expr {
        return expression() // should error handle with exceptions
    }
    
    private func expression() -> Expr {
        return equality()
    }

    private func equality() -> Expr {
        var expr = comparison()

        while match(.BANG_EQUAL, .EQUAL_EQUAL) {
            let op = previous()
            let right = comparison()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func comparison() -> Expr {
        var expr = addition()

        while match(.GREATER, .GREATER_EQUALS, .LESS, .LESS_EQUALS) {
            let op = previous()
            let right = addition()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func addition() -> Expr {
        var expr = multiplication()

        while match(.MINUS, .PLUS) {
            let op = previous()
            let right = multiplication()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func multiplication() -> Expr {
        var expr = unary()

        while match(.SLASH, .STAR) {
            let op = previous()
            let right = multiplication()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func unary() -> Expr {
        if match(.BANG, .MINUS) {
            let op = previous()
            let right = unary()
            return Unary(op: op, right: right)
        }
        
        return primary()
    }
    
    private func primary() -> Expr {
        if match(.NAHH) { return Literal(value: false)}
        if match(.YERR) { return Literal(value: true)}
        if match(.NADA) { return Literal(value: nil)}
        
        if match(.NUMBER, .STRING) {
            return Literal(value: previous().literal)
        }
        
        if match(.LPAREN) {
            let expr = expression()
            _ = consume(type: .RPAREN, message: "no rparen doe")
            return Grouping(expression: expr)
        }
        
        fatalError("expected expression")
    }
    
    private func match(_ types: TokenType...) -> Bool {
        for type in types {
            if check(type) {
                _ = advance()
                return true
            }
        }
        
        return false
    }
    
    private func check(_ type: TokenType) -> Bool {
        if isAtEnd() { return false }
        return peek().tokenType == type
    }
    
    
    private func advance() -> Token {
        if !isAtEnd() { current += 1}
        return previous()
    }
    
    private func isAtEnd() -> Bool {
        return peek().tokenType == .EOF
    }
    
    private func peek() -> Token {
        return tokens[current]
    }
    
    private func previous() -> Token {
        return tokens[current - 1]
    }
    
    private func consume(type: TokenType, message: String) -> Token {
        if check(type) { return advance() }
        
        fatalError("da fuck: \(message)")
    }
    
}
