//
//  Parser.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import Foundation

class Parser {
    
    // MARK: - Internal Properties
    /// A delegate for further handling of certain `Parser` events such as when output is available or a session ends.
    var delegate: ParserDelegate?
    
    // MARK: - Private Properties
    /// Stores the key-value pairs extracted from assignment operations in the input
    private lazy var storage: Dictionary<String, Int> = [String: Int]()
    /// Stores the lines of code within a function definition, to be executed in order when the function is called
    private lazy var function = [String]()
    /// The function name extracted from the function definition input
    private var functionName: String?
    /// The computer instance for the current session
    private var computer: Computer?
    /// The computer name extracted from the input; used to determine when a `Computer` instance method is called
    private var computerName: String?
    /// Represents text that any delegate may use to display output to the user
    private var output = "" {
        didSet {
            delegate?.parserDidSendOutput(message: output)
        }
    }

    // MARK: - Internal Functions
    /**
     Parses and executes the contents of `Input.txt`.
     */
    func readFromFile() {
        output = Messages.ReadingInput

        if let path = Bundle.main.path(forResource: Constants.InputFileName, ofType: Constants.InputFileType) {
            do {
                let data = try String.init(contentsOfFile: path, encoding: .utf8)
                let myStrings = data.components(separatedBy: .newlines)
                for line in myStrings {
                    output = "> \(line)"
                    parse(line: line)
                }
            }
            catch {
            }
        }
    }
    
    /**
     Passes a line of input - either from a file or from user input via the UI - to the parser.
     
     - Parameter _: The line to be parsed
     */
    func readLine(_ line: String) {
        parse(line: line)
    }
    
    // MARK: - Private Functions
    
    /**
     Determines whether a line of text falls into a command category and executes a corresponding set of methods based on the category.
     
     A line may belong to at most one of the following command categories:
     - **Session End** - Ends the current session
     - **Comment or White Space** - Ignored by the parser
     - **Function End** - Marks the end of a function definition
     - **Function Code** - Represents a line of code within the function
     - **Assignment** - Represents an assignment operation
     - **Function Start** - Marks the start of a function definition
     - **Function Call** - Starts the execution of the defined function
     
     - Parameter line: The line to be parsed
     */
    private func parse(line: String) {
        
        if line.matches(pattern: Patterns.Exit) {
            output = Messages.SessionEnded
            resetParser()
            delegate?.parserDidEndSession()
            return
        }
        
        if isCommentOrWhiteSpace(line) {
            return
        }
        
        if line.matches(pattern: Patterns.FunctionEnd) {
            function.append(Constants.FunctionStackEndMarker)
            return
        }
        
        if let _ = functionName, function.last != Constants.FunctionStackEndMarker {
            function.append(line)
            return
        }

        if line.matches(pattern: Patterns.Assignment) {
            extractKeyValue(from: line)
            return
        }
        
        if line.matches(pattern: Patterns.FunctionDefinition) {
            extractFunctionName(from: line)
            return
        }
        
        if isFunctionCall(line) {
            executeFunctionCall()
            return
        }
    }
    
    /**
     Resets the properties used by the parser to allow for a new session.
     */
    private func resetParser() {
        storage = [String: Int]()
        function = [String]()
        functionName = nil
        computer =  nil
        computerName = nil
    }
    
    // MARK: Categorization
    /**
     Returns whether a line is a function call.
     
     - Parameter _: The line to be processed
     */
    private func isFunctionCall(_ line: String) -> Bool {
        guard let name = functionName else {
            return false
        }
        
        // [0 or more spaces][functionName][1 or more spaces][starts with a char][0 or more alphanumeric chars or _][0 or more spaces]
        let pattern = "^\\h*\(name)\\(\\)\\h*$"
        return line.matches(pattern: pattern)
    }
    
    /**
     Returns whether the line calls the computer's' instance method.
     
     - Parameter _: The line to be processed
     */
    private func isComputerInstanceMethod(_ line: String) -> Bool {
        guard let name = computerName else {
            return false
        }
        
        let pattern = "\\h*\(name)\\."
        return line.matches(pattern: pattern)
    }
    
    /**
     Returns whether a line is a comment or purely whitespace.
     
     - Parameter _: The line to be processed
     */
    private func isCommentOrWhiteSpace(_ line: String) -> Bool {
        return line.trimmingCharacters(in: .whitespacesAndNewlines).first == "#"
    }
    
    // MARK: Commands Execution
    /**
     Extracts the key and value components of an assignment operation and saves them to storage.
     
     - Parameter from: The line containing the assignment operation
     */
    private func extractKeyValue(from line: String) {
        let assignment = line.removeWhiteLine().split(separator: "=")
        storage[String(assignment[0])] = Int(assignment[1])
    }
    
    /**
     Extracts the name of a function.
     
     - Parameter from: The line containing the function definition
     */
    private func extractFunctionName(from line: String) {
        functionName = line.components(separatedBy: Constants.FunctionDefinitionStartMarker).last?.removeWhiteLine()
    }
    
    /**
     Starts the execution of the defined function.
     */
    private func executeFunctionCall() {
        for line in function {
            if line == Constants.FunctionStackEndMarker {
                break
            }
            
            if line.matches(pattern: Patterns.ComputerInit) {
                initializeComputer(line: line)
                continue
            }
            
            if isComputerInstanceMethod(line) {
                guard let name = computerName else {
                    return
                }

                let commands = line.replacingOccurrences(of: "\(name).", with: "").components(separatedBy: ".")
                for command in commands {
                    processComputerInstanceMethod(command)
                }
            }
        }
    }
    
    /**
     Creates a new `Computer` using properties extracted from the line.
     
     - Parameter line: The line from which to extract the computer's properties for initialization
     
     Once the computer is successfully initialized, self is set as its delegate to receive data from the computer.
     */
    private func initializeComputer(line: String) {
        if let range = line.range(of: "\\d+", options: .regularExpression) {
            guard let stackSize = Int(line[range]) else {
                return
            }
            
            let assignment = line.removeWhiteLine().split(separator: "=")
            computerName = String(assignment[0])
            computer = Computer.new(size: stackSize)
            computer?.delegate = self
        }
    }

    /**
     Categorizes and executes a computer's instance method.
     
     - Parameter _: The line containing the call to one of `Computer`'s instance methods
     */
    private func processComputerInstanceMethod(_ command: String) {
        if command.matches(pattern: Patterns.SetAddress) {
            setAddress(command: command)
        }
        else if command.matches(pattern: Patterns.Insert) {
            insertInstruction(command: command)
        }
        else if command.matches(pattern: Patterns.Execute) {
            if case let .Failure(message) = computer?.execute() {
                output = message
            }
        }
    }
    
    /**
     Calls the computer's `set_address` instance method based on the address value in the command input.
     
     - Parameter command: The line containing the set_address command
     */
    private func setAddress(command: String) {
        let address = command.replacingOccurrences(of: "set_address(", with: "").replacingOccurrences(of: ")", with: "")
        if let addr = Int(address) {
            if case let .Failure(message) = computer?.set_address(addr) {
                output = message
            }
        }
        else if let addr = storage[address] {
            if case let .Failure(message) = computer?.set_address(addr) {
                output = message
            }
        }
    }
    
    /**
     Calls the computer's `insert` method based on the instruction in the command input.
     
     - Parameter command: The line containing the insert command
     */
    private func insertInstruction(command: String) {
        let instruction = command.replacingOccurrences(of: "insert(\"", with: "").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ")", with: "").removeWhiteLine().components(separatedBy: ",")

        if instruction.count > 1 {
            if let arg = Int(instruction[1]) {
                if case let .Failure(message) = computer?.insert(instruction: instruction[0], argument: arg) {
                    output = message
                }
            }
            else if let arg = storage[instruction[1]] {
                if case let .Failure(message) = computer?.insert(instruction: instruction[0], argument: arg) {
                    output = message
                }
            }
        }
        else if instruction.count == 1 {
            if case let .Failure(message) = computer?.insert(instruction: instruction[0], argument: nil) {
                output = message
            }
        }
    }
}


// MARK: - ComputerDelegate Delegate Functions Implementation
extension Parser: ComputerDelegate {
    func computerDidSendOutput(_ update: String) {
        output = update
    }
}

// MARK: - ParserDelegate Declaration
/**
 A set of methods that can be used to perform additional tasks after certain `Parser` events.
 */
protocol ParserDelegate {
    func parserDidSendOutput(message: String)
    func parserDidEndSession()
}

// MARK: - String Extension Methods
extension String {
    
    /**
     Returns whether a string matches the given regular expression
     
     - Parameter pattern: A regular expression to match against the string
     */
    func matches(pattern: String) -> Bool {
        guard let _ = self.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
            return false
        }
        return true
    }
    
    /**
     Returns the string without spaces
     */
    func removeWhiteLine() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}
