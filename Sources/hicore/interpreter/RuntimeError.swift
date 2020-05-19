//
//  RuntimeError.swift
//  
//
//  Created by Kevin Turner on 5/18/20.
//

import Foundation


struct RuntimeError: Error {
    let tok: Token
    let message: String
    
    init(tok: Token, message: String) {
        self.tok = tok
        self.message = message
    }
}
