//
//  Clock.swift
//  
//
//  Created by Kevin Turner on 5/20/20.
//

import Foundation
import CoreFoundation

class Clock: HiCallable {
    func arity() -> Int {
        return 0
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) -> Any? {
        return NSDate().timeIntervalSince1970 as Double
    }
    
}
