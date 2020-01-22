//
//  Constants.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 31/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import Foundation

/// A set of localizable error messages
enum Errors {
    static let PcOutOfBounds = NSLocalizedString("ERROR_PC_OUT_OF_BOUNDS", comment: "")
    static let NoInstructionAtAddress = NSLocalizedString("ERROR_NO_INSTRUCTION_AT_ADDRESS", comment: "")
    static let InvalidArgument = NSLocalizedString("ERROR_INVALID_ARGUMENT", comment: "")
    static let InvalidInstruction = NSLocalizedString("ERROR_INVALID_INSTRUCTION", comment: "")
    static let InvalidInput = NSLocalizedString("ERROR_INVALID_INPUT", comment: "")
    static let InvalidArgumentMult = NSLocalizedString("ERROR_INVALID_ARGUMENT_MULT", comment: "")
    static let InvalidArgumentCall = NSLocalizedString("ERROR_INVALID_ARGUMENT_CALL", comment: "")
    static let InvalidArgumentRetInt = NSLocalizedString("ERROR_INVALID_ARGUMENT_RET_INT", comment: "")
    static let InvalidArgumentRetAddress = NSLocalizedString("ERROR_INVALID_ARGUMENT_RET_ADDRESS", comment: "")
    static let InvalidArgumentPrint = NSLocalizedString("ERROR_INVALID_ARGUMENT_PRINT", comment: "")
}

/// A set of localizable informational messages
enum Messages {
    static let ReadingInput = NSLocalizedString("MESSAGE_READING_INPUT", comment: "")
    static let SessionEnded = NSLocalizedString("MESSAGE_SESSION_ENDED", comment: "")
    static let MenuPrompt = NSLocalizedString("MESSAGE_MENU_PROMPT", comment: "")
    static let ManualInputInstruction = NSLocalizedString("MESSAGE_MANUAL_INPUT_INSTRUCTION", comment: "")
    static let ReadFromFileInstruction = NSLocalizedString("MESSAGE_READ_FROM_FILE_INSTRUCTION", comment: "")
}

/// A set of regular expression strings for matching against commands
enum Patterns {
    // TODO: Improve precision of these regular expressions

    // exit()
    static let Exit = "^\\h*exit\\(\\)\\h*$"
    
    // [0 or more spaces][starts with a char or _][0 or more alphanumeric chars or _][0 or more spaces]=[0 or more spaces][1 or more digits][0 or more spaces]
    static let Assignment = "\\h*[a-zA-Z_][a-zA-Z0-9_]*\\h*=\\h*[0-9]+\\h*"
    
    // [0 or more spaces]def[1 or more spaces][starts with a char][0 or more alphanumeric chars or _][0 or more spaces]
    static let FunctionDefinition = "\\h*^def\\h+[a-zA-Z][a-zA-Z0-9_]*\\h*"
    
    // [0 or more spaces]end[0 or more spaces]
    static let FunctionEnd = "\\h*^end\\h*"
    
    // [0 or more spaces][starts with a char or _][0 or more alphanumeric chars or _][0 or more spaces]=[0 or more spaces]Computer.new([1 or more digits])[0 or more spaces]
    static let ComputerInit = "\\h*[a-zA-Z_][a-zA-Z0-9_]*\\h*=\\h*Computer.new\\([0-9]+\\)\\h*"

    static let SetAddress = "set_address\\([a-zA-Z0-9_]+\\)"
    
    static let Insert = "insert\\(\"[a-zA-Z_]+\"(,[\t\r ]*[a-zA-Z0-9_]+)?\\)*"
    
    static let Execute = "execute\\(\\)"
}

/// A set of values indicating the result of an execution
enum Result {
    /// Indicates that the execution was successful.
    ///
    /// The associated value may contain a value significant to the executed instruction.
    case Success(Int?)
    
    /// Indicates that the execution failed.
    ///
    /// The associated value should contain an error message for the user.
    case Failure(String)
}

/// A set of constants used throughout the application
enum Constants {
    static let InputFileName = "Input"
    static let InputFileType = "txt"
    static let FunctionStackEndMarker = "END"
    static let FunctionDefinitionStartMarker = "def"
    static let DefaultComputerStackSize = 100
}
