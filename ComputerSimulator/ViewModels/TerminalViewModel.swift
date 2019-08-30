//
//  TerminalViewModel.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 30/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import Foundation

class TerminalViewModel {
    
    var terminalOutputUpdated: ((String) -> Void)?
    var showPrompt: ((String?, ((String) -> Void)?) -> Void)?

    var outputText: String? {
        didSet {
            if let newText = outputText {
                if let oldText = history {
                    history = "\(oldText)\n\(newText)"
                }
                else {
                    history = newText
                }
                terminalOutputUpdated?(history ?? "")
            }
        }
    }
    
    var mainPrompt = "[1] Type in commands\n[2] Read from input file"
    
    private var parser: Parser
    private var history: String?

    init(withParser parser: Parser) {
        self.parser = parser
        self.parser.delegate = self
    }

    func terminalInputReceived(_ choice: String) {
        switch Int(choice) {
        case 1:
            showPrompt?("Please type in commands line by line. Type exit() to end session.", readLine)
        case 2:
            parser.readFromFile()
        default:
            outputText = "Invalid input"
        }
    }
        
    private func readLine(_ line: String) {
        parser.readLine(line)
    }
}

extension TerminalViewModel: ParserDelegate {

    func onTerminalOutputUpdated(_ update: String?) {
        outputText = update
    }
}
