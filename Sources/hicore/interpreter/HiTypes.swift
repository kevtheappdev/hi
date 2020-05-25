//
//  HiType.swift
//  Prototype universal object model
//
//  Created by Kevin Turner on 5/24/20.
//

import Foundation


class HiType: CustomStringConvertible {
    
    var description: String {
        get {
            return "nada"
        }
    }
}

class HiNumber: HiType {
    override var description: String {
        get {
            let str = String(describing: self.value)
            if str.hasSuffix(".0"), let index = str.lastIndex(of: ".") {
                return String(str[str.startIndex..<index])
            }
            return str
        }
    }
    
    var value: Double
    
    
    init(value: Double) {
        self.value = value
    }
    
    static func + (lhs: HiNumber, rhs: HiNumber) -> HiNumber {
        return HiNumber(value: lhs.value + rhs.value)
    }
    
    static func * (lhs: HiNumber, rhs: HiNumber) -> HiNumber {
        return HiNumber(value: lhs.value * rhs.value)
    }
}
