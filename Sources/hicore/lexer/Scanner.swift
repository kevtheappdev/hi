//
//  Scanner.swift
//  
//
//  Created by Kevin Turner on 4/17/20.
//

import Foundation

public class Scanner {
    private let source: String
    private var tokens = Array<Token>()
    
    private var start: String.Index
    private var current: String.Index
    private var line = 0
    
    private static var reserved: Dictionary<String, TokenType> = {
        var reservedKwds = Dictionary<String, TokenType>()
        reservedKwds["and"] = .AND
        reservedKwds["class"] = .CLASS
        reservedKwds["else"] = .ELSE
        reservedKwds["nahh"] = .NAHH
        reservedKwds["fun"] = .FUN
        reservedKwds["for"] = .FOR
        reservedKwds["if"] = .IF
        reservedKwds["nada"] = .NADA
        reservedKwds["hi"] = .HI
        reservedKwds["or"] = .OR
        reservedKwds["print"] = .PRINT
        reservedKwds["return"] = .RETURN
        reservedKwds["super"] = .SUPER
        reservedKwds["self"] = .SELF
        reservedKwds["yerr"] = .YERR
        reservedKwds["var"] = .VAR
        reservedKwds["while"] = .WHILE
        
        return reservedKwds
    }()
    
    public init(withSource source: String) {
        self.source = source
        self.current = source.startIndex
        self.start = self.current
    }
    
    public func scanTokens() -> Swift.Result<Array<Token>, Error> {
        while !isAtEnd() {
            start = current
            do {
                try scanToken()
            } catch ScannerErrors.unexpectedToken(let line) {
                return .failure(ScannerErrors.unexpectedToken(line: line))
            } catch {
                fatalError("shit: \(error) with tokens: \(tokens)") // TODO: make this some generic error
            }
        }
        
        tokens.append(Token(withType: .EOF, lexeme: "", line: line, literal: nil))
        return .success(tokens)
    }
    
    private func scanToken() throws {
        let c = advance()
        switch (c) {
        case "(": addToken(ofType: .LPAREN); break
        case ")": addToken(ofType: .RPAREN); break
        case "{": addToken(ofType: .LBRACE); break
        case "}": addToken(ofType: .RBRACE); break
        case ",": addToken(ofType: .COMMA); break
        case ".": addToken(ofType: .DOT); break
        case "-": addToken(ofType: .MINUS); break
        case "+": addToken(ofType: .PLUS); break
        case ";": addToken(ofType: .SEMICOLON); break
        case "*": addToken(ofType: .STAR); break
        case "!": addToken(ofType: match(expected: "=") ? .BANG_EQUAL : .BANG); break
        case "=": addToken(ofType: match(expected: "=") ? .EQUAL_EQUAL : .EQUAL); break
        case "<": addToken(ofType: match(expected: "=") ? .LESS_EQUALS : .LESS); break
        case ">": addToken(ofType: match(expected: "=") ? .GREATER_EQUALS : .GREATER); break
        case "/":
            if (match(expected: "/")) {
                while (peek() != "\n" && !isAtEnd()) { _ = advance() } // comments
            } else {
                addToken(ofType: .SLASH)
            }
        
        case "\r", " ", "\t": // ignore whitespace
            break
        
        case "\"": try string(); break
        case "\n": line += 1; break
            
        default:
            if isDigit(c) {
                number()
            } else if isAlpha(c) {
                identifier()
            } else {
                print("bouta throw the error\(c)")
                throw ScannerErrors.unexpectedToken(line: line)
            }
        }
    }
    
    private func isDigit(_ c: Character) -> Bool {
        return c >= "0" && c <= "9"
    }
    
    private func isAlpha(_ c: Character) -> Bool {
        return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || (c == "_")
    }
    
    private func isAlphaNumeric(_ c: Character) -> Bool {
        return isAlpha(c) || isDigit(c)
    }
    
    private func identifier() {
        while isAlphaNumeric(peek()) { _ = advance() }
        
        let text = String(source[start..<current])
        if let reservedKwd = Scanner.reserved[text] {
            addToken(ofType: reservedKwd)
        } else {
            addToken(ofType: .IDENTIFIER)
        }
    }
    
    private func number() {
        while isDigit(peek()) { _ = advance() }
        
        // look for fractional point
        if peek() == "." && isDigit(peekNext()) {
            _ = advance()
            
            while isDigit(peek()) { _ = advance()}
        }
        
        addToken(ofType: .NUMBER, withLiteral: Double(String(source[start..<current])) as AnyObject)
    }
    
    private func string() throws { // handle string literals
        while peek() != "\"" && !isAtEnd() {
            if (peek() == "\n") {
                line += 1
            }
            _ = advance()
        }
        
        // Unterminated string
        if isAtEnd() {
            throw ScannerErrors.unterminatedString(line: line)
        }
        
        _ = advance() // the closing "
        
        // trim the surrounding quotes
        let stringStart = source.index(after: start)
        let stringEnd = source.index(before: current)
        let value = String(source[stringStart..<stringEnd])
        addToken(ofType: .STRING, withLiteral: value as AnyObject)
    }
    
    private func peek() -> Character {
        if isAtEnd() { return "\0" }
        return source[current]
    }
    
    private func peekNext() -> Character {
        let nextIndex = source.index(after: current)
        if nextIndex > source.endIndex { return "\0"} // TODO: \0 may not equate to the null character
        return source[nextIndex]
    }
    
    private func match(expected: Character) -> Bool {
        if isAtEnd() { return false }
        if source[current] != expected { return false}
        
        current = source.index(after: current)
        return true
    }
    
    private func advance() -> Character {
        let result = source[current]
        current = source.index(after: current)
        return result
    }
    
    private func addToken(ofType type: TokenType, withLiteral literal: AnyObject? = nil) {
        let lexeme = String(source[start..<current])
        tokens.append(Token(withType: type, lexeme: lexeme, line: line, literal: literal))
    }
    
    private func isAtEnd() -> Bool {
        return current > source.index(before: source.endIndex)
    }
    
}
