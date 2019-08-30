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

    private var stack: [StackItem?]
    
    var size: Int {
        return stack.count
    }

    init(size: Int) {
        //stack.reserveCapacity(size)
        stack = [StackItem?](repeating: nil, count: size)
    }

    mutating func push(_ item: StackItem) {
        stack.append(item)
    }
    
    mutating func pop() -> StackItem?? {
        return stack.popLast()
    }
    
    mutating func insert(_ item: StackItem, at index: Int) -> Result{
        if size > 0, index >= size {
            return .Failure(Errors.PcOutOfBounds)
        }

        stack[index] = item
        return .Success(nil)
    }
    
    func peek(at index: Int) -> StackItem? {
        return stack[index]
    }
}
