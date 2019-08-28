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
        return Computer(stack: stack, programCounter: 0)
    }
    
    mutating func set_address(_ address: Int) -> Result {
        if address >= stack.size {
            // TODO: Proper error handling
            return .Failure("Program counter is out of bounds.")
        }
        programCounter = address
        return .Success(nil)
    }
    
    mutating func insert(instruction: String, argument: Int?) -> Result {
        
        switch instruction {
        case Instruction.MULT.rawValue,
             Instruction.RET.rawValue,
             Instruction.STOP.rawValue,
             Instruction.PRINT.rawValue:
            stack.insert((instruction, nil), at: programCounter)
        case Instruction.CALL.rawValue,
             Instruction.PUSH.rawValue:
            guard let arg = argument else {
                return .Failure("Argument is invalid.")
            }
            stack.insert((instruction, arg), at: programCounter)
        default:
            // TODO: Proper error handling
            return .Failure("Invalid instruction")
        }
        
        // TODO: Check result of stack.insert
        programCounter += 1
        return .Success(nil)
    }
    
    // TODO: Improve implementation and error handling
    mutating func execute() {
        var instruction = ""
        var argument: Int?
        repeat {
            if let (instruction, argument) = stack.peek(at: programCounter) {
                switch instruction {
                case Instruction.MULT.rawValue:
                    computerMultiply()
                case Instruction.CALL.rawValue:
                    guard let arg = argument else {
                        return
                    }
                    computerCall(argument: arg)
                case Instruction.RET.rawValue:
                    computerReturn()
                case Instruction.PRINT.rawValue:
                    computerPrint()
                case Instruction.PUSH.rawValue:
                    guard let arg = argument else {
                        return
                    }
                    computerPush(argument: arg)
                default:
                    return
                }
                
                if (instruction != Instruction.CALL.rawValue && instruction != Instruction.RET.rawValue) {
                    programCounter += 1
                }
                
            }
        }
        while instruction != Instruction.STOP.rawValue
    }
    
    private mutating func computerMultiply() -> Result {
        guard let (_, arg1) = stack.pop() ?? nil, let (_, arg2) = stack.pop() ?? nil, let multiplicand1 = arg1, let multiplicand2 = arg2 else {
            return .Failure("Cannot execute MULT instruction. An item in the stack is not a valid integer.")
        }
        
        stack.push(("", multiplicand1 * multiplicand2))
        return .Success(nil)
    }
    
    private mutating func computerCall(argument: Int) -> Result {
        if argument >= stack.size {
            return .Failure("Cannot execute CALL instruction. Address is out of bounds.")
        }
        
        return set_address(argument)
    }
    
    private mutating func computerReturn() -> Result {
        guard let (_, address) = stack.pop() ?? nil, let addr = address else {
            return .Failure("Cannot execute RET instruction. Address is not a valid integer.")
        }

        if (addr >= stack.size) {
            return .Failure("Cannot execute RET instruction. Address is out of bounds.")
        }

        programCounter = addr
        return .Success(nil)
    }
    
    private func computerStop() -> Result {
        // TODO: Implement stop
        return .Success(nil)
    }
    
    private mutating func computerPrint() -> Result {
        guard let (_, arg) = stack.pop() ?? nil, let value = arg else {
            return .Failure("Cannot execute PRINT instruction. Value is not a valid integer.")
        }
        
        print(value)
        return .Success(value)
    }
    
    private mutating func computerPush(argument: Int) -> Result {
        stack.push(("", argument))
        return .Success(nil)
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
    case Success(Int?)
    case Failure(String)
}
