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
    
    public func parse() -> Swift.Result<Array<Stmt>, Error> {
        var statements = Array<Stmt>()
        do {
            while !isAtEnd() {
                statements.append(try declaration())
            }
            return .success(statements)
        } catch {
            return .failure(ParseError())
        }
        
    }
    
    private func declaration() throws -> Stmt {
        if match(.VAR) { return try varDeclaration() }
        return try statement()
    }
    
    private func varDeclaration() throws -> Stmt {
        let name = try consume(type: .IDENTIFIER, message: "Expect variable name")
        
        var initializer: Expr? = nil
        if match(.EQUAL) {
            initializer = try expression()
        }
        
        _ = try consume(type: .SEMICOLON, message: "Expect ';' after variable declaration.")
        return Var(name: name, initializer: initializer)
    }
    
    private func statement() throws -> Stmt {
        if match(.PRINT) { return try printStatement() }
        if match(.LBRACE) { return Block(statements: try block())}
        
        return try expressionStatement()
    }
    
    private func block() throws -> Array<Stmt> {
        var statements = Array<Stmt>()
        
        while !check(.RBRACE) && !isAtEnd() {
            statements.append(try declaration())
        }
        
        _ = try consume(type: .RBRACE, message: "Expect '}' after block.")
        return statements
    }
    
    private func printStatement() throws -> Stmt {
        let value = try expression()
        try _ = consume(type: .SEMICOLON, message: "Expect ';' after value")
        return Print(expression: value)
    }
    
    private func expressionStatement() throws -> Stmt {
        let expr = try expression()
        try _ = consume(type: .SEMICOLON, message: "Expect ';' after expression.")
        return Expression(expression: expr)
    }
    
    private func synchronize() {
        _ = advance()
        
        while !isAtEnd() {
            if previous().tokenType == .SEMICOLON { return }
            if match(.CLASS, .FUN, .VAR, .FOR, .IF, .WHILE, .PRINT, .RETURN) { return }
            _ = advance()
        }
    }
    
    private func expression() throws -> Expr {
        return try assignment()
    }
    
    private func assignment() throws -> Expr {
        let expr = try equality()
        
        if match(.EQUAL) {
            let equals = previous()
            let value = try assignment()
            
            if expr is Variable {
                let name = (expr as! Variable).name
                return Assign(name: name, value: value)
            }
            
            _ = error(withTok: equals, andMessage: "Invalid assignment target.")
        }
        
        return expr
    }

    private func equality() throws -> Expr {
        var expr = try comparison()

        while match(.BANG_EQUAL, .EQUAL_EQUAL) {
            let op = previous()
            let right = try comparison()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func comparison() throws -> Expr {
        var expr = try addition()

        while match(.GREATER, .GREATER_EQUALS, .LESS, .LESS_EQUALS) {
            let op = previous()
            let right = try addition()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func addition() throws -> Expr {
        var expr = try multiplication()

        while match(.MINUS, .PLUS) {
            let op = previous()
            let right = try multiplication()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func multiplication() throws -> Expr {
        var expr = try unary()

        while match(.SLASH, .STAR) {
            let op = previous()
            let right = try unary()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func unary() throws -> Expr {
        if match(.BANG, .MINUS) {
            let op = previous()
            let right = try unary()
            return Unary(op: op, right: right)
        }
        
        return try primary()
    }
    
    private func primary() throws -> Expr {
        if match(.NAHH) { return Literal(value: false)}
        if match(.YERR) { return Literal(value: true)}
        if match(.NADA) { return Literal(value: nil)}
        
        if match(.NUMBER, .STRING) {
            return Literal(value: previous().literal)
        }
        
        if match(.IDENTIFIER) {
            return Variable(name: previous())
        }
        
        if match(.LPAREN) {
            let expr = try expression()
            _ = try consume(type: .RPAREN, message: "no rparen doe")
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
    
    private func consume(type: TokenType, message: String) throws -> Token {
        if check(type) { return advance() }
        
        throw error(withTok: peek(), andMessage: message)
    }
    
    private func error(withTok tok: Token, andMessage message: String) -> ParseError {
        Hi.error(tok.line, message)
        return ParseError()
    }
    
}
