//
//  HiType.swift
//  
//
//  Created by Kevin Turner on 5/24/20.
//

import Foundation


class HiType: Comparable {
    static func < (lhs: HiType, rhs: HiType) -> Bool {
        return false
    }
    
    static func == (lhs: HiType, rhs: HiType) -> Bool {
        return lhs === rhs
    }

}

class HiNumber: HiType {
    var value: Double
    
    init(value: Double) {
        self.value = value
    }
    
}
