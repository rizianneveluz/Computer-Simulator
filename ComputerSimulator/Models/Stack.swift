//
//  Stack.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import Foundation

struct Stack {

    // MARK: - Internal Properties
    /// Returns the current stack size
    var size: Int {
        return stack.count
    }
    /// The element type expected by the internal stack
    typealias StackItem = (String, Int?)

    // MARK: - Private Properties
    /// The `Stack`'s internal data structure consisting of optional `StackItem`s
    private var stack: [StackItem?]
    
    // MARK: - Initialization
    /**
     Initialize a new `Stack`with the specified size.
     
     If the given size is less than 1, the stack is instead created using a default size.
     Upon initialization, the stack is populated with nil items
     
     - Parameter size: The intended size of the stack
     */
    init(size: Int) {
        var stackSize = size
        if size < 1 {
            stackSize = Constants.DefaultComputerStackSize
        }
        stack = [StackItem?](repeating: nil, count: stackSize)
    }

    // MARK: - Internal Functions
    /**
     Appends a new item to the stack.
     
     - Parameter _: The item to be added to the end of the stack
     */
    mutating func push(_ item: StackItem) {
        stack.append(item)
    }
    
    /**
     Removes and returns the latest item in the stack.
     
     Since a `Stack` is a collection of optional `StackItems`, the pop operation yields two possibilities:
     - Retrieving an item (of type `StackItem?`)
     - Retrieving nil, if the stack is empty
     
     - Returns: A double optional `StackItem`
     */
    mutating func pop() -> StackItem?? {
        return stack.popLast()
    }
    
    /**
     Inserts a new item to the stack, at the specified index.
     
     - Parameters:
        - _: The item to be added to the stack
        - at: The index in which the item should be inserted
     */
    mutating func insert(_ item: StackItem, at index: Int) -> Result {
        // Check for the following conditions:
        // 1. Stack is not empty (currently should not happen since initialization defaults to a certain number if passed size is < 1)
        // 2. Index is within the stack's current size
        if size > 0, index >= size {
            return .Failure(Errors.PcOutOfBounds)
        }

        stack[index] = item
        return .Success(nil)
    }
    
    /**
     Returns the item at the specified index.
     
     - Parameter at: The index to access
     */
    func peek(at index: Int) -> StackItem? {
        // Instead of returning an error, return nil if index is out of bounds
        if index >= size {
            return nil
        }
        return stack[index]
    }
}
