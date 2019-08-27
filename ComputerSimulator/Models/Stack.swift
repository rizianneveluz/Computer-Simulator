//
//  Stack.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import Foundation

struct Stack {

    internal typealias StackItem = (String, Int?)

    private var stack = [StackItem]()
    
    var size: Int {
        return stack.count
    }

    init(size: Int) {
        stack.reserveCapacity(size)
    }

    mutating func push(_ item: StackItem) {
        stack.append(item)
    }
    
    mutating func pop() -> StackItem? {
        return stack.popLast()
    }
    
    mutating func insert(_ item: StackItem, at index: Int) -> Result{
        if index >= size {
            return .Failure("Program counter is out of bounds.")
        }

        stack.insert(item, at: index)
        return .Success(nil)
    }
}
