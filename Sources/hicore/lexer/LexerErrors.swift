//
//  LexerErrors.swift
//  
//
//  Created by Kevin Turner on 4/17/20.
//

import Foundation

public enum ScannerErrors: Error {
    case unexpectedToken(line: Int)
    case unterminatedString(line: Int)
}
