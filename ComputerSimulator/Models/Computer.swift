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
    private(set) var programCounter: Int
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
        if address >= stack.size || address < 0 {
            return .Failure(Errors.PcOutOfBounds)
        }

        programCounter = address
        return .Success(address)
    }
    
    mutating func insert(instruction: String, argument: Int?) -> Result {
        var result: Result

        switch instruction {
        case Instruction.MULT.rawValue,
             Instruction.RET.rawValue,
             Instruction.STOP.rawValue,
             Instruction.PRINT.rawValue:
                result = stack.insert((instruction, nil), at: programCounter)
        case Instruction.CALL.rawValue,
             Instruction.PUSH.rawValue:
                guard let arg = argument else {
                    return .Failure(Errors.InvalidArgument)
                }
                result = stack.insert((instruction, arg), at: programCounter)
        default:
            return .Failure(Errors.InvalidInstruction)
        }
        
        if case .Success(_) = result {
            programCounter += 1
        }
        
        return result
    }
    
    mutating func execute() -> Result {
        var result = Result.Success(nil)
        var instruction = ""
        
        guard let _ = stack.peek(at: programCounter) else {
            return .Failure(Errors.NoInstructionAtAddress)
        }

        repeat {
            if let (instr, argument) = stack.peek(at: programCounter) {
                instruction = instr

                switch instr {
                case Instruction.MULT.rawValue:
                    result = computerMultiply()
                case Instruction.CALL.rawValue:
                    guard let arg = argument else {
                        return .Failure(Errors.InvalidArgumentCall)
                    }
                    result = computerCall(argument: arg)
                case Instruction.RET.rawValue:
                    result = computerReturn()
                case Instruction.PRINT.rawValue:
                    result = computerPrint()
                case Instruction.PUSH.rawValue:
                    guard let arg = argument else {
                        return .Failure(Errors.InvalidArgument)
                    }
                    computerPush(argument: arg)
                case Instruction.STOP.rawValue:
                    return result
                default:
                    return .Failure(Errors.InvalidInstruction)
                }
                
                if case .Failure(_) = result {
                    return result
                }
            }
            
            if (instruction != Instruction.CALL.rawValue && instruction != Instruction.RET.rawValue) {
                programCounter += 1
            }
        }
            while instruction != Instruction.STOP.rawValue || programCounter < stack.size
        return result
    }
    
    private mutating func computerMultiply() -> Result {
        guard let (instr1, arg1) = stack.pop() ?? nil, let (instr2, arg2) = stack.pop() ?? nil, let factor1 = arg1, let factor2 = arg2, instr1 == "", instr2 == "" else {
            return .Failure(Errors.InvalidArgumentMult)
        }
        
        let product = factor1 * factor2
        stack.push(("", product))
        return .Success(product)
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
        return .Success(addr)
    }
    
    private mutating func computerPrint() -> Result {
        guard let (instruction, arg) = stack.pop() ?? nil, let value = arg, instruction == ""  else {
            return .Failure(Errors.InvalidArgumentPrint)
        }
        
        delegate?.onComputerOutputAvailable(String(value))
        return .Success(value)
    }
    
    private mutating func computerPush(argument: Int) {
        stack.push(("", argument))
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
