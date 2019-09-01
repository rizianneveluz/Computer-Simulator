//
//  Computer.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import Foundation

class Computer {
    
    // MARK: - Internal Properties
    /// A delegate for further handling of certain `Computer` events such as when output is available.
    var delegate: ComputerDelegate?
    /// The address of the command the computer will execute next or is currently executing.
    private(set) var programCounter: Int
    
    // MARK: - Private Properties
    /// The computer's internal `Stack`
    private var stack: Stack
    /// Represents text that any delegate may use to display output to the user
    private var output = "" {
        didSet {
            delegate?.computerDidSendOutput(output)
        }
    }
    
    // MARK: - Initialization
    /**
     `Computer`'s public constructor.
     
     This is the only publicly-accessibly function that can be used to create a new instance of `Computer`.
     
     - Parameter size: The computer's stack size.
     */
    static func new(size: Int) -> Computer {
        let stack = Stack.init(size: size)
        return Computer(stack: stack, programCounter: 0)
    }
    
    /**
    Creates a new instance of `Computer` and initializes it with the specified stack size and program counter.
     
     - Parameters:
        - stack: An instance of `Stack` which will be used as the computer's internal data structure
        - programCounter: The initial address where the computer will start execution
     */
    private init(stack: Stack, programCounter: Int) {
        self.stack = stack
        self.programCounter = programCounter
    }
    
    // MARK: - Internal Functions
    /**
     Sets the computer's current address of execution.
     
     - Parameter _: the new address
     - Returns:
        - `Result.Failure(Errors.PcOutOfBounds)` if the given address is out of bounds
        - `Result.Success(address)` otherwise
     */
    func set_address(_ address: Int) -> Result {
        if address >= stack.size || address < 0 {
            return .Failure(Errors.PcOutOfBounds)
        }

        programCounter = address
        return .Success(address)
    }
    
    /**
     Inserts an instruction and optional parameter into the computer's stack and increments the program counter.
     
     - Parameters:
        - instruction: the type of command to execute
        - argument: the instruction's argument
     
     - Returns:
        - `Result.Failure(Errors.InvalidArgument)` if no argument is passed for instructions that require an argument
        - `Result.Failure(Errors.InvalidInstruction)` if the given instruction is not supported by `Computer`
        - `Result.Success(Int?)` otherwise. The actual associated value depends on the executed instruction
     */
    func insert(instruction: String, argument: Int?) -> Result {
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
    
    /**
     Starts the execution of commands in the computer's stack.
     
     Execution stops when a `STOP` instruction is encountered or if the end of the stack is reached.
     
     - Returns:
        - `Result.Failure(Errors.NoInstructionAtAddress)` if the item at the current address is nil
        - `Result.Failure(Errors.InvalidArgumentCall)` if no argument is passed for `CALL`
        - `Result.Failure(Errors.InvalidArgument)` if no argument is passed for `PUSH`
        - `Result.Failure(Errors.InvalidInstruction)` if the instruction is not supported by `Computer`
        - `Result.Success(Int?)` otherwise. The actual associated value depends on the executed instruction
     */
    func execute() -> Result {
        var result = Result.Success(nil)
        var instruction = ""
        
        guard let _ = stack.peek(at: programCounter) else {
            // The StackItem at the current address is nil
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
                    result = computerCall(address: arg)
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
                
                // Do not increment the program counter if execution of current instruction failed
                if case .Failure(_) = result {
                    return result
                }
            }
            
            // Program counter should not increment if current instruction is CALL or RET.
            // Both of these instructions set the new address instead
            if (instruction != Instruction.CALL.rawValue && instruction != Instruction.RET.rawValue) {
                programCounter += 1
            }
        }
            while instruction != Instruction.STOP.rawValue || programCounter < stack.size
        return result
    }
    
    // MARK: - Private Functions
    /**
     Executes the `MULT` instruction.
     
     - Returns:
        - `Result.Failure(Errors.InvalidArgumentMult)` if any of the following conditions are not met:
            - The two latest items in the stack are not nil
            - The argument component of the two latest items in the stack are not nil
            - The instruction component of the two latest item in the stack is empty, indicating that these are pushed values. This prevents the computer from using arguments intended for other instructions.
        - `Result.Success(product)` otherwise
     */
    private func computerMultiply() -> Result {
        guard let (instr1, arg1) = stack.pop() ?? nil,
            let (instr2, arg2) = stack.pop() ?? nil,
            let factor1 = arg1, let factor2 = arg2,
            instr1 == "", instr2 == "" else {
            return .Failure(Errors.InvalidArgumentMult)
        }
        
        let product = factor1 * factor2
        stack.push(("", product))
        return .Success(product)
    }
    
    /**
     Executes the `CALL` instruction.
     
     - Parameter address: the address to be called
     
     - Returns:
        - `Result.Failure(Errors.InvalidArgumentCall)` if the specified address is out of bounds
        - `Result.Success(address)` otherwise
     */
    private func computerCall(address: Int) -> Result {
        if address >= stack.size || address < 0 {
            return .Failure(Errors.InvalidArgumentCall)
        }
        
        return set_address(address)
    }
    
    /**
     Executes the `RET` instruction.
     
     - Returns:
        - `Result.Failure(Errors.InvalidArgumentRetInt)` if any of the following conditions are not met:
            - The latest item in the stack is not nil
            - The argument component of the latest item in the stack is not nil
            - The instruction component of the latest item in the stack is empty, indicating that this is a pushed value. This prevents the computer from using arguments intended for other instructions.
        - `Result.Failure(Errors.InvalidArgumentRetAddress)` if the value of the latest item in the stack is out of bounds
        - `Result.Success(address)` otherwise
     */
    private func computerReturn() -> Result {
        guard let (instr, address) = stack.pop() ?? nil,
            let addr = address,
            instr == "" else {
            return .Failure(Errors.InvalidArgumentRetInt)
        }

        if (addr >= stack.size) {
            return .Failure(Errors.InvalidArgumentRetAddress)
        }

        programCounter = addr
        return .Success(addr)
    }
    
    /**
     Executes the `PRINT` instruction.
     
     - Returns:
        - `Result.Failure(Errors.InvalidArgumentPrint)` if any of the following conditions are not met:
            - The latest item in the stack is not nil
            - The argument component of the latest item in the stack is not nil
            - The instruction component of the latest item in the stack is empty, indicating that this is a pushed value. This prevents the computer from using arguments intended for other instructions.
        - `Result.Success(value)` otherwise
     */
    private func computerPrint() -> Result {
        guard let (instruction, arg) = stack.pop() ?? nil,
            let value = arg,
            instruction == "" else {
            return .Failure(Errors.InvalidArgumentPrint)
        }
        
        // Notify any delegate that a computer output is available
        output = String(value)
        return .Success(value)
    }
    
    /**
     Executes the `PUSH` instruction.
     
     - Parameter argument: The value to be pushed to the stack
     */
    private func computerPush(argument: Int) {
        stack.push(("", argument))
    }
}

/// The set of instructions supported by `Computer`
fileprivate enum Instruction: String {
    /// Pop the two latest values from the stack, multiply them, then push the result back to the stack
    case MULT
    /// Set the program counter
    case CALL
    /// Pop the latest argument from the stack then set the program counter
    case RET
    /// Stop the execution of the program
    case STOP
    /// Pop the latest value from stack then print it
    case PRINT
    /// Push argument to the stack
    case PUSH
}

// MARK: - ComputerDelegate Declaration
/**
 A set of methods that can be used to perform additional tasks after certain `Computer` events.
 */
protocol ComputerDelegate {
    mutating func computerDidSendOutput(_ update: String)
}
