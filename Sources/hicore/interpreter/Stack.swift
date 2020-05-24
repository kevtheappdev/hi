//
//  File.swift
//  
//
//  Created by Kevin Turner on 5/21/20.
//

import Foundation

class Node<T> {
    var next: Node?
    var val: T
    
    init(val: T, next: Node? = nil) {
        self.val = val
        self.next = next
    }
}

class Stack<T> {
    
}
