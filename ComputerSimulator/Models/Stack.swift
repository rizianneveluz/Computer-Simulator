//
//  Stack.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import Foundation

struct Stack {

    private var stack = [String]()
    
    var pointer: Int {
        return stack.count
    }

    init(size: Int) {
        stack.reserveCapacity(size)
    }

    mutating func push(item: String) {
        stack.append(item)
    }
    
    mutating func pop() -> String? {
        return stack.popLast()
    }
}
