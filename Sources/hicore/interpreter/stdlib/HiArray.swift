//
//  HiArray.swift
//  
//
//  Created by Kevin Turner on 5/24/20.
//

import Foundation

class ArrayGetter: HiCallable {
    var instance: HiArrrayInstance
    
    init(instance: HiArrrayInstance) {
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
    var instance: HiArrrayInstance
    
    init(instance: HiArrrayInstance) {
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


class HiArrrayInstance: HiInstance {
    
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
    
    override func get(index: Token) throws -> Any? {
        if index.lexeme == "get" {
            return ArrayGetter(instance: self)
        } else if index.lexeme == "length" {
            return Double(data.count)
        } else if index.lexeme == "set" {
            return ArraySetter(instance: self)
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
            return HiArrrayInstance(size: Int(size))
        }
        
        throw ArgumentError()
    }
}
