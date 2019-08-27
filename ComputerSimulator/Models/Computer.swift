//
//  Computer.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import Foundation

struct Computer {
    
    private var stack: Stack
    private var programCounter: Int
    
    static func new(size: Int) -> Computer {
        let stack = Stack.init(size: size)
        return Computer(stack: stack, programCounter: size)
    }
    
    mutating func set_address(_ address: Int) {
    }
    
    mutating func insert(instruction: String, argument: Int?) {
    }
    
    func execute() {
    }
}

enum Instruction: String {
    case MULT
    case CALL
    case RET
    case STOP
    case PRINT
    case PUSH
}

enum Result {
    // TODO: Change Result's associated values
    case Success
    case Failure
}
