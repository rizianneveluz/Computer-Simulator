//
//  Parser.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import Foundation

class Parser {
    private lazy var storage: Dictionary<String, Int> = [String: Int]()
    private lazy var function = [String]()
    private var functionName: String?
    private var computer: Computer?
    private var computerName: String?
    var delegate: ParserDelegate?
    
    var latestOutput = "" {
        didSet {
            delegate?.onTerminalOutputUpdated(latestOutput)
        }
    }

    func readFromFile() {
        latestOutput = Messages.ReadingInput

        if let path = Bundle.main.path(forResource: Constants.InputFileName, ofType: Constants.InputFileType) {
            do {
                let data = try String.init(contentsOfFile: path, encoding: .utf8)
                let myStrings = data.components(separatedBy: .newlines)
                for line in myStrings {
                    latestOutput = "> \(line)"
                    parse(line: line)
                }
            }
            catch {
            }
        }
    }
    
    func readLine(_ line: String) {
        parse(line: line)
    }
    
    private func parse(line: String) {
        
        if line.matches(pattern: Patterns.Exit) {
            latestOutput = Messages.SessionEnded
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
            extractAssignment(from: line)
            return
        }
        
        if line.matches(pattern: Patterns.FunctionDefinition) {
            extractFunctionDefinition(from: line)
            return
        }
        
        if isFunctionCall(line) {
            executeFunctionCall()
            return
        }
    }
    
    private func extractAssignment(from line: String) {
        let assignment = line.removeWhiteLine().split(separator: "=")
        storage[String(assignment[0])] = Int(assignment[1])
    }
    
    private func extractFunctionDefinition(from line: String) {
        functionName = line.components(separatedBy: Constants.FunctionDefinitionStartMarker).last?.removeWhiteLine()
    }
    
    private func isFunctionCall(_ line: String) -> Bool {
        guard let name = functionName else {
            return false
        }
        
        // [0 or more spaces][functionName][1 or more spaces][starts with a char][0 or more alphanumeric chars or _][0 or more spaces]
        let pattern = "\\h*^\(name)\\h*"
        return line.matches(pattern: pattern)
    }
    
    private func executeFunctionCall() {
        for line in function {
            if line == "END" {
                break
            }
            
            if line.matches(pattern: Patterns.ComputerInit) {
                initializeComputer(line: line)
                continue
            }
            
            if isComputerFunction(line) {
                guard let name = computerName else {
                    return
                }

                let commands = line.replacingOccurrences(of: "\(name).", with: "").components(separatedBy: ".")
                for command in commands {
                    processComputerFunction(command)
                }
            }
        }
    }
    
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
    
    private func isComputerFunction(_ line: String) -> Bool {
        guard let name = computerName else {
            return false
        }
        
        let pattern = "\\h*\(name)\\."
        return line.matches(pattern: pattern)
    }

    private func processComputerFunction(_ command: String) {
        if command.matches(pattern: Patterns.SetAddress) {
            setAddress(command: command)
        }
        else if command.matches(pattern: Patterns.Insert) {
            performInstruction(command: command)
        }
        else if command.matches(pattern: Patterns.Execute) {
            if case let .Failure(message) = computer?.execute() {
                latestOutput = message
            }
        }
    }
    
    private func isCommentOrWhiteSpace(_ line: String) -> Bool {
        return line.trimmingCharacters(in: .whitespacesAndNewlines).first == "#"
    }
    
    private func setAddress(command: String) {
        let address = command.replacingOccurrences(of: "set_address(", with: "").replacingOccurrences(of: ")", with: "")
        if let addr = Int(address) {
            if case let .Failure(message) = computer?.set_address(addr) {
                latestOutput = message
            }
        }
        else if let addr = storage[address] {
            if case let .Failure(message) = computer?.set_address(addr) {
                latestOutput = message
            }
        }
    }
    
    private func performInstruction(command: String) {
        let instruction = command.replacingOccurrences(of: "insert(\"", with: "").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ")", with: "").removeWhiteLine().components(separatedBy: ",")

        if instruction.count > 1 {
            if let arg = Int(instruction[1]) {
                if case let .Failure(message) = computer?.insert(instruction: instruction[0], argument: arg) {
                    latestOutput = message
                }
            }
            else if let arg = storage[instruction[1]] {
                if case let .Failure(message) = computer?.insert(instruction: instruction[0], argument: arg) {
                    latestOutput = message
                }
            }
        }
        else if instruction.count == 1 {
            if case let .Failure(message) = computer?.insert(instruction: instruction[0], argument: nil) {
                latestOutput = message
            }
        }
    }
}

extension Parser: ComputerDelegate {
    func onComputerOutputAvailable(_ update: String) {
        latestOutput = update
    }
}

protocol ParserDelegate {
    func onTerminalOutputUpdated(_ update: String?)
}

extension String {
    func matches(pattern: String) -> Bool {
        guard let _ = self.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
            return false
        }
        return true
    }
    
    func removeWhiteLine() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}
