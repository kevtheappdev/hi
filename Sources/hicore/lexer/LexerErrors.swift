//
//  LexerErrors.swift
//  
//
//  Created by Kevin Turner on 4/17/20.
//

import Foundation

public enum ScannerErrors: Error {
    // TODO: have more clarity for error types
    case unexpectedToken(line: Int, message: String)
    case unterminatedString(line: Int, message: String)
}
