//
//  TerminalViewModel.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 30/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import Foundation

class TerminalViewModel {
    
    
    var didReceiveMenuInput: ((String) -> Void)?
    var didReceiveCommandInput: ((String) -> Void)?
    
    // MARK - Output properties
    var showMenuPrompt: (() -> Void)?
    var showCommandPrompt: (() -> Void)?
    var didUpdateHistory: (() -> Void)?
    
    // MARK - Input functions
    func didStartUp() {
        didUpdateHistory?()
        showMenuPrompt?()
    }
    
    // MARK - Private properties
    private var parser: Parser
    private(set) var history = Messages.MenuPrompt

    init(withParser parser: Parser) {
        self.parser = parser
        self.parser.delegate = self
    }

    func didReceiveMenuInput(choice: String) {
        appendToHistory(choice)

        switch Int(choice) {
        case 1:
            appendToHistory(Messages.ManualInputInstruction)
            showCommandPrompt?()
        case 2:
            parser.readFromFile()
            appendToHistory(Messages.ReadFromFileInstruction)
            showCommandPrompt?()
        default:
            appendToHistory(Errors.InvalidInput)
        }
    }
    
    func didReceiveCommandInput(command: String) {
        appendToHistory(command)
        parser.readLine(command)
    }
    
    private func returnToMainMenu() {
        appendToHistory(Messages.MenuPrompt)
        showMenuPrompt?()
    }
    
    private func appendToHistory(_ line: String) {
        history = "\(history)\n\(line)"
        didUpdateHistory?()
    }
}

extension TerminalViewModel: ParserDelegate {

    func didFinishParsing(message: String) {
        appendToHistory(message)
    }
    
    func didEndSession() {
        returnToMainMenu()
    }
}
