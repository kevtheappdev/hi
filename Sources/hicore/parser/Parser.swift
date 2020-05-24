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
        if match(.FUN) { return try function("function")}
        if match(.CLASS) { return try classDeclaration()}
        if match(.VAR) { return try varDeclaration() }
        return try statement()
    }
    
    private func classDeclaration() throws -> Stmt {
        let name = try consume(type: .IDENTIFIER, message: "Expected name after class declaration.")
        
        var superclass: Variable? = nil
        if match(.LESS) {
            _ = try consume(type: .IDENTIFIER, message: "Expect superclass name.")
            superclass = Variable(name: previous())
        }
        
        _ = try consume(type: .LBRACE, message: "Expected '}' ")
        
        var methods = Array<Function>()
        while !check(.RBRACE) && !isAtEnd() {
            methods.append(try function("method"))
        }
        
        _ = try consume(type: .RBRACE, message: "Expect '}' after class body")
        return Class(name: name, methods: methods, superclass: superclass)
    }
    
    private func function(_ kind: String) throws -> Function {
        let name = try consume(type: .IDENTIFIER, message: "Expect \(kind) name.")
        _ = try consume(type: .LPAREN, message: "Expect '(' after \(kind) name")
        var params = Array<Token>()
        if !check(.RPAREN) {
            repeat {
                if params.count >= 255 { _ = error(withTok: peek(), andMessage: "Can't have mroe than 255 \(kind) parameters")}
                params.append(try consume(type: .IDENTIFIER, message: "Expected identifier"))
            } while match(.COMMA)
        }
        
        _ = try consume(type: .RPAREN, message: "Exptected RPAREN after function declaration")
        _ = try consume(type: .LBRACE, message: "Expected '{' after \(kind) declaration")
        
        let body = try block()
        return Function(name: name, params: params, body: body)
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
        if match(.IF) { return try ifStatement()}
        if match(.PRINT) { return try printStatement() }
        if match(.RETURN) { return try returnStatement()}
        if match(.WHILE) { return try whileStatement()}
        if match(.LBRACE) { return Block(statements: try block())}
        
        return try expressionStatement()
    }
    
    private func returnStatement() throws -> Return {
        let kwd = previous()
        var val: Expr? = nil
        
        if !check(.SEMICOLON) {
            val = try expression()
        }
        
        _ = try consume(type: .SEMICOLON, message: "Expected ';' after return")
        return Return(kwd: kwd, value: val)
    }
    
    private func block() throws -> Array<Stmt> {
        var statements = Array<Stmt>()
        
        while !check(.RBRACE) && !isAtEnd() {
            statements.append(try declaration())
        }
        
        _ = try consume(type: .RBRACE, message: "Expect '}' after block.")
        return statements
    }
    
    private func whileStatement() throws -> Stmt {
        let condition = try expression()
        let body = try statement()
        
        return While(condition: condition, body: body)
    }
    
    private func ifStatement() throws -> Stmt {
        let condition = try expression()
        let thenBranch = try statement()
        
        var elseBranch: Stmt? = nil
        if match(.ELSE) {
            elseBranch = try statement()
        }
        
        return If(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
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
        let expr = try or()
        
        if match(.EQUAL) {
            let equals = previous()
            let value = try assignment()
            
            if expr is Variable {
                let name = (expr as! Variable).name
                return Assign(name: name, value: value)
            } else if expr is Get {
                let get = expr as! Get
                return Set(obj: get.obj, name: get.name, value: value)
            }
            
            _ = error(withTok: equals, andMessage: "Invalid assignment target.")
        }
        
        return expr
    }
    
    private func or() throws -> Expr {
        var expr = try and()
        
        while match(.OR) {
            let op = previous()
            let right = try and()
            expr = Logical(left: expr, op: op, right: right)
        }
        
        return expr
    }
    
    private func and() throws -> Expr {
        var expr = try equality()
        
        while match(.AND) {
            let op = previous()
            let right = try equality()
            expr = Logical(left: expr, op: op, right: right)
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
        
        return try call()
    }
    
    private func call() throws -> Expr {
        var expr = try primary()
        
        while true {
            if match(.LPAREN) {
                expr = try finishCall(expr)
            } else if match(.DOT) {
                let name = try consume(type: .IDENTIFIER, message: "Expected property name after '.'")
                expr = Get(obj: expr, name: name)
            } else {
                break
            }
        }
        
        return expr
    }
    
    private func finishCall(_ callee: Expr) throws -> Expr {
        var args = Array<Expr>()
        if !check(.RPAREN) {
            repeat {
                if args.count >= 255 { _ = error(withTok: peek(), andMessage: "Too many args for function")}
                args.append(try expression())
            } while match(.COMMA)
        }
        
        let paren = try consume(type: .RPAREN, message: "Expect ')' to complete function call")
        return Call(callee: callee, paren: paren, arguments: args)
    }
    
    private func primary() throws -> Expr {
        if match(.NAHH) { return Literal(value: false)}
        if match(.YERR) { return Literal(value: true)}
        if match(.NADA) { return Literal(value: nil)}
        
        if match(.NUMBER, .STRING) {
            return Literal(value: previous().literal)
        }
        
        if match(.LSQUARE) {
            var contents = Array<Expr>()
            if !check(.RSQUARE) {
                repeat {
                    let expr = try expression()
                    contents.append(expr)
                } while match(.COMMA)
            }
            _ = try consume(type: .RSQUARE, message: "Expect closing ']' for array literal")
            return Literal(value: contents)
        }
        
        if match(.SUPER) {
            let kwd = previous()
            _ = try consume(type: .DOT, message: "Expect '.' after 'super'.")
            let method = try consume(type: .IDENTIFIER, message: "Expect superclass method name")
            return Super(kwd: kwd, method: method)
        }
        
        if match(.SELF) {
            return HiSelf(kwd: previous())
        }
        
        if match(.IDENTIFIER) {
            return Variable(name: previous())
        }
        
        if match(.LPAREN) {
            let expr = try expression()
            _ = try consume(type: .RPAREN, message: "no rparen doe")
            return Grouping(expression: expr)
        }
        
        throw ParseError() // be more specific here
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
