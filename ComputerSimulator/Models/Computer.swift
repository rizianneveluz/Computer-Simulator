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
    var delegate: ComputerDelegate?

    var output = "" {
        didSet {
            delegate?.onComputerOutputAvailable(output)
        }
    }
    
    static func new(size: Int) -> Computer {
        let stack = Stack.init(size: size)
        return Computer(stack: stack, programCounter: 0)
    }
    
    mutating func set_address(_ address: Int) -> Result {
        if address >= stack.size {
            // TODO: Proper error handling
            return .Failure(Errors.PcOutOfBounds)
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
                return .Failure(Errors.InvalidArgument)
            }
            stack.insert((instruction, arg), at: programCounter)
        default:
            // TODO: Proper error handling
            return .Failure(Errors.InvalidInstruction)
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
            return .Failure(Errors.InvalidArgumentMult)
        }
        
        stack.push(("", multiplicand1 * multiplicand2))
        return .Success(nil)
    }
    
    private mutating func computerCall(argument: Int) -> Result {
        if argument >= stack.size {
            return .Failure(Errors.InvalidArgumentCall)
        }
        
        return set_address(argument)
    }
    
    private mutating func computerReturn() -> Result {
        guard let (_, address) = stack.pop() ?? nil, let addr = address else {
            return .Failure(Errors.InvalidArgumentRetInt)
        }

        if (addr >= stack.size) {
            return .Failure(Errors.InvalidArgumentRetAddress)
        }

        programCounter = addr
        return .Success(nil)
    }
    
    private func computerStop() -> Result {
        return .Success(nil)
    }
    
    private mutating func computerPrint() -> Result {
        guard let (_, arg) = stack.pop() ?? nil, let value = arg else {
            return .Failure(Errors.InvalidArgumentPrint)
        }
        
        delegate?.onComputerOutputAvailable(String(value))
        return .Success(value)
    }
    
    private mutating func computerPush(argument: Int) -> Result {
        stack.push(("", argument))
        return .Success(nil)
    }
}

fileprivate enum Instruction: String {
    case MULT
    case CALL
    case RET
    case STOP
    case PRINT
    case PUSH
}

protocol ComputerDelegate {
    mutating func onComputerOutputAvailable(_ update: String)
}
