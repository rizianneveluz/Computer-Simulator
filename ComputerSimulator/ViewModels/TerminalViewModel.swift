//
//  TerminalViewModel.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 30/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import Foundation

class TerminalViewModel {
    
    // MARK: - Input Properties
    /// Notifies the view model that the view received a menu input
    var didReceiveMenuInput: ((String) -> Void)?
    /// Notifies the view model that the view received a command input
    var didReceiveCommandInput: ((String) -> Void)?
    
    // MARK: - Output properties
    /// Notifies the view controller to show the menu prompt
    var showMenuPrompt: (() -> Void)?
    /// Notifies the view controller to show a command prompt
    var showCommandPrompt: (() -> Void)?
    /// Notifies the view controller that the terminal history was updated
    var didUpdateHistory: (() -> Void)?
    
    // MARK: - Private properties
    /// The terminal's parser
    private var parser: Parser
    /// The terminal view's text history
    private(set) var history = Messages.MenuPrompt
    
    // MARK: - Internal Functions
    init(withParser parser: Parser) {
        self.parser = parser
        self.parser.delegate = self
    }
    
    /**
     Notifies the view controller to perform initial functions
     */
    func startUp() {
        didUpdateHistory?()
        showMenuPrompt?()
    }
    
    /**
     Performs actions based on the user's menu input
     
     - Parameter choice: The user's menu input
     */
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
    
    /**
     Feeds the user's command input to the parser
     
     - Parameter command: The user's command input
     */
    func didReceiveCommandInput(command: String) {
        appendToHistory(command)
        parser.readLine(command)
    }
    
    // MARK: - Private Functions
    /**
     Notifies the view controller to show the main menu prompt
     */
    private func returnToMainMenu() {
        appendToHistory(Messages.MenuPrompt)
        showMenuPrompt?()
    }
    
    /**
     Adds a new line to the terminal view's text history
     
     - Parameter _: The new line to append
     */
    private func appendToHistory(_ line: String) {
        history = "\(history)\n\(line)"
        didUpdateHistory?()
    }
}

// MARK: - ParserDelegate Delegate Functions Implementation
extension TerminalViewModel: ParserDelegate {

    func parserDidSendOutput(message: String) {
        appendToHistory(message)
    }
    
    func parserDidEndSession() {
        returnToMainMenu()
    }
}
