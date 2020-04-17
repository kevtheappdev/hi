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
    
    init(withSource source: String) {
        self.source = source
        self.current = source.startIndex
        self.start = self.current
    }
    
    func scanTokens() -> Result<Array<Token>, Error> {
        while !isAtEnd() {
            start = current
            
            do {
                try scanToken()
            } catch ScannerErrors.unexpectedToken {
                return .failure(ScannerErrors.unexpectedToken)
            } catch {
                fatalError("never") // TODO: make this some generic error
            }
        }
        
        return .success(tokens)
    }
    
    private func scanToken() throws {
        let c = advance()
        switch (c) {
        case "(": addToken(ofType: .LPAREN); break
        case ")": addToken(ofType: .RPAREN); break
        case "{": addToken(ofType: .LBRACE); break
        case "}": addToken(ofType: .RBRACE); break
            
        default:
            throw ScannerErrors.unexpectedToken
        }
        
    }
    
    private func advance() -> Character {
        current = source.index(after: current)
        return source[current]
    }
    
    private func addToken(ofType type: TokenType, withLiteral literal: AnyObject? = nil) {
        let lexeme = String(source[start..<current])
        tokens.append(Token(withType: type, lexeme: lexeme, line: line, literal: literal))
    }
    
    func isAtEnd() -> Bool {
        return current < source.endIndex
    }
    
}
