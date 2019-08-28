//
//  Parser.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import Foundation

struct Parser {
    private lazy var storage: Dictionary<String, Int> = [String: Int]()
    private lazy var function = [String]()
    private var functionName: String?
    private var computer: Computer?
    private var computerName: String?
    
    init() {
        // Currently, input is read off of a text file
        // TODO: Allow user to input code from UI
        if let path = Bundle.main.path(forResource: "Input", ofType: "txt") {
            do {
                let data = try String.init(contentsOfFile: path, encoding: .utf8)
                let myStrings = data.components(separatedBy: .newlines)
                for line in myStrings {
                    parse(line: line)
                }
            }
            catch {
            }
        }
    }
    
    private mutating func parse(line: String) {
        
        if isCommentOrWhiteSpace(line) {
            return
        }
        
        if isFunctionEnd(line) {
            function.append("END")
            return
        }
        
        if let _ = functionName, function.last != "END" {
            function.append(line)
            return
        }

        if isAssignment(line) {
            extractAssignment(from: line)
            return
        }
        
        if isFunctionDefinition(line) {
            extractFunctionDefinition(from: line)
            return
        }
        
        if isFunctionCall(line) {
            executeFunctionCall()
            return
        }
    }
    
    private func isAssignment(_ line: String) -> Bool {
        // [0 or more spaces][starts with a char or _][0 or more alphanumeric chars or _][0 or more spaces]=[0 or more spaces][1 or more digits][0 or more spaces]
        let pattern = "\\h*[a-zA-Z_][a-zA-Z0-9_]*\\h*=\\h*[0-9]+\\h*"
        guard let _ = line.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
            return false
        }
        return true
    }
    
    private mutating func extractAssignment(from line: String) {
        let assignment = line.replacingOccurrences(of: " ", with: "").split(separator: "=")
        storage[String(assignment[0])] = Int(assignment[1])
    }
    
    private func isFunctionDefinition(_ line: String) -> Bool {
        // [0 or more spaces]def[1 or more spaces][starts with a char][0 or more alphanumeric chars or _][0 or more spaces]
        let pattern = "\\h*^def\\h+[a-zA-Z][a-zA-Z0-9_]*\\h*"
        guard let _ = line.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
            return false
        }
        return true
    }
    
    private mutating func extractFunctionDefinition(from line: String) {
        functionName = line.components(separatedBy: "def").last?.replacingOccurrences(of: " ", with: "")
    }
    
    private func isFunctionEnd(_ line: String) -> Bool {
        // [0 or more spaces]end[0 or more spaces]
        let pattern = "\\h*^end\\h*"
        guard let _ = line.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
            return false
        }

        return true
    }
    
    private func isFunctionCall(_ line: String) -> Bool {
        guard let name = functionName else {
            return false
        }

        // [0 or more spaces][functionName][1 or more spaces][starts with a char][0 or more alphanumeric chars or _][0 or more spaces]
        let pattern = "\\h*^\(name)\\h*"
        guard let _ = line.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
            return false
        }
        return true
    }
    
    private mutating func executeFunctionCall() {
        for line in function {
            if line == "END" {
                break
            }
            
            if isComputerInit(line) {
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
    
    private func isComputerInit(_ line: String) -> Bool {
        // [0 or more spaces][starts with a char or _][0 or more alphanumeric chars or _][0 or more spaces]=[0 or more spaces]Computer.new([1 or more digits])[0 or more spaces]
        let pattern = "\\h*[a-zA-Z_][a-zA-Z0-9_]*\\h*=\\h*Computer.new\\([0-9]+\\)\\h*"
        guard let _ = line.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
            return false
        }
        return true
    }
    
    private mutating func initializeComputer(line: String) {
        if let range = line.range(of: "\\d+", options: .regularExpression) {
            guard let stackSize = Int(line[range]) else {
                return
            }
            
            let assignment = line.replacingOccurrences(of: " ", with: "").split(separator: "=")
            computerName = String(assignment[0])
            computer = Computer.new(size: stackSize)
        }
    }
    
    private func isComputerFunction(_ line: String) -> Bool {
        guard let name = computerName else {
            return false
        }
        
        let pattern = "\\h*\(name)\\."
        guard let _ = line.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
            return false
        }

        return true
    }

    private mutating func processComputerFunction(_ command: String) {
        var pattern = "set_address\\([a-zA-Z_]+\\)" // SET_ADDRESS
        guard let _ = command.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
            
            pattern = "insert\\(\"[a-zA-Z_]+\"(,[\t\r ]*[a-zA-Z0-9_]+)?\\)*" // INSERT
            guard let _ = command.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
                
                pattern = "execute\\(\\)" // EXECUTE
                guard let _ = command.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
                    return
                }
                
                computer?.execute()
                
                return
            }
            
            performInstruction(command: command)
            return
        }
        
        setAddress(command: command)
    }
    
    private func isCommentOrWhiteSpace(_ line: String) -> Bool {
        guard let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines).first else {
            return true
        }
        
        return trimmed == "#"
    }
    
    private mutating func setAddress(command: String) {
        let address = command.replacingOccurrences(of: "set_address(", with: "").replacingOccurrences(of: ")", with: "")
        if let addr = Int(address) {
            computer?.set_address(addr)
        }
        else if let addr = storage[address] {
            computer?.set_address(addr)
        }
    }
    
    private mutating func performInstruction(command: String) {
        let instruction = command.replacingOccurrences(of: "insert(\"", with: "").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
        if instruction.count > 1 {
            if let arg = Int(instruction[1]) {
                computer?.insert(instruction: instruction[0], argument: arg)
            }
            else if let arg = storage[instruction[1]] {
                computer?.insert(instruction: instruction[0], argument: arg)
            }
        }
        else if instruction.count == 1 {
            computer?.insert(instruction: instruction[0], argument: nil)
        }
    }
}
