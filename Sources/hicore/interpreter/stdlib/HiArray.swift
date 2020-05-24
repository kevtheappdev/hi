//
//  HiArray.swift
//  
//
//  Created by Kevin Turner on 5/24/20.
//

import Foundation


class ArrayAdder: HiCallable {
    var instance: HiArrayInstance
    
    init(instance: HiArrayInstance) {
        self.instance = instance
    }
    
    func arity() -> Int {
        return 1
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        self.instance.data.append(args[0])
        return nil
    }
}

class ArrayGoodSorter: HiCallable {
    var instance: HiArrayInstance
    
    init(instance: HiArrayInstance) {
        self.instance = instance
    }
    
    func arity() -> Int {
        return 0
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        if !instance.isUniform() { throw ArgumentError() }
        if instance.data.count == 0 { return nil }
        if instance.data[0] is Double {
            var numArray = instance.numberArray()
            numArray.sort()
            instance.data = numArray
        }
        
        return nil
    }
}

class ArraySorter: HiCallable {
    var instance: HiArrayInstance
    
    init(instance: HiArrayInstance) {
        self.instance = instance
    }

    func numArraySorted() -> Bool {
        let numArray = instance.numberArray()
        var last = numArray[0]
        for i in 1..<numArray.count {
            if numArray[i] < last {
                return false
            }
            last = numArray[i]
        }
        return true
    }
    
    func arity() -> Int {
        return 0
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        if !instance.isUniform() { throw ArgumentError() } // TODO: make more specific
        if instance.data.count == 0 {
            return nil
        }
        
        if instance.data[0] is Double {
            while !numArraySorted() {
                instance.data.shuffle()
            }
        } else {
            throw ArgumentError() // TODO: be more specific and fill out other types
        }
        
        
        return nil
    }
}

class ArrayGetter: HiCallable {
    var instance: HiArrayInstance
    
    init(instance: HiArrayInstance) {
        self.instance = instance
    }
    
    func arity() -> Int {
        return 1
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        if let index = args[0] as? Double {
            return instance.data[Int(index)]
        }
        
        throw ArgumentError()
    }
}

class ArraySetter: HiCallable {
    var instance: HiArrayInstance
    
    init(instance: HiArrayInstance) {
        self.instance = instance
    }
    
    func arity() -> Int {
        return 2
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        if let index = args[0] as? Double {
            instance.data[Int(index)] = args[1]
            return nil
        }
        
        throw ArgumentError()
    }
}


class HiArrayInstance: HiInstance {
    
    var data: Array<Any?>
    
    override var description: String {
        get {
            var result = "["
            for (index, item) in data.enumerated() {
                if let nonNilItem = item, let strConvertible = nonNilItem as? CustomStringConvertible {
                    result += String(describing: strConvertible)
                } else {
                    result += "nil"
                }
                if index != data.count - 1 {
                    result += ", "
                }
            }
            return result + "]"
        }
    }

    init(size: Int) {
        data = Array<Any?>(repeating: nil, count: size)
        let hiClass = HiClass(name: "Array", methods: Dictionary<String, HiFunction>(), superclass: nil)
        super.init(klass: hiClass)
    }
    
    func numberArray() -> Array<Double> {
        var nums = Array<Double>()
        for item in data {
            nums.append(item as! Double)
        }
        return nums
    }
    
    
    func isUniform() -> Bool {
        if data.count == 0 { return true }
        var last = data[0]
        for i in 1..<data.count {
            let curr = data[i]
            if object_getClassName(curr) != object_getClassName(last) {
                return false
            }
            last = curr
        }
        
        return true
    }
    
    override func get(index: Token) throws -> Any? {
        if index.lexeme == "get" {
            return ArrayGetter(instance: self)
        } else if index.lexeme == "length" {
            return Double(data.count)
        } else if index.lexeme == "set" {
            return ArraySetter(instance: self)
        } else if index.lexeme == "sort" {
            return ArraySorter(instance: self)
        } else if index.lexeme == "add" {
            return ArrayAdder(instance: self)
        } else if index.lexeme == "goodSort" {
            return ArrayGoodSorter(instance: self)
        }
        
        throw RuntimeError(tok: index, message: "Undefined property \(index.lexeme)")
    }
}


class HiArray: HiCallable {
    var data: Array<Any?>!
    
    func arity() -> Int {
        return 1
    }
    
    func call(_ interpreter: Interpreter, args: Array<Any?>) throws -> Any? {
        if let size = args[0] as? Double {
            return HiArrayInstance(size: Int(size))
        }
        
        throw ArgumentError()
    }
}
