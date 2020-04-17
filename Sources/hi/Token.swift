//
//  Token.swift
//  
//
//  Created by Kevin Turner on 4/17/20.
//

import Foundation

public enum TokenType {
    case IDENTIFIER
    case STRING
    case NMBER
    case LPAREN
    case RPAREN
    case LBRACE
    case RBRACE
    case COMMA
    case DOT
    case MINUS
    case PLUS
    case SEMICOLON
    case SLASH
    case STAR
    case AND
    case CLASS
    case ELSE
    case IF
    case FUN
    case HI
    case NADA
    case PRINT
    case RETURN
    case YERR
    case NAHH
    case EQUAL
    case GREATER
    case GREATER_EQUALS
    case LESS
    case LESS_EQUALS
}

class Token {
    let tokenType: TokenType
    let lexeme: String
    let line: Int
    let literal: AnyObject?
    
    init(withType type: TokenType, lexeme: String, line: Int, literal: AnyObject?) {
        self.tokenType = type
        self.lexeme = lexeme
        self.line = line
        self.literal = literal
    }
}
