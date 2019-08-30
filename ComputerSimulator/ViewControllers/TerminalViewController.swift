//
//  TerminalViewController.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import UIKit

class TerminalViewController: UIViewController, ParserDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var outputView: UILabel!
    @IBOutlet weak var terminalInputView: UITextField!

    private let parser = Parser()
    private var inputCompletionHandler: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        terminalInputView.becomeFirstResponder()
        terminalInputView.tintColor = #colorLiteral(red: 0.4234788418, green: 0.8100475669, blue: 0.4512391686, alpha: 1)
        terminalInputView.delegate = self
        
        parser.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showPrompt(message: "[1] Type in commands\n[2] Read from input file", completionHandler: { choice in
            switch Int(choice) {
            case 1:
                if let output = self.outputView.text {
                    self.outputView.text = "\(output)\nPlease type in commands line by line"
                    self.showPrompt(message: nil, completionHandler: { line in
                        self.parser.readLine(line)
                    })
                }
            case 2:
                self.parser.readFromFile()
            default:
                if let output = self.outputView.text {
                    self.outputView.text = "\(output)\nInvalid input"
                }
            }
        })
    }
    
    private func showPrompt(message: String?, completionHandler: ((String) -> Void)?) {
        if let msg = message {
            outputView.text = msg
        }
        
        inputCompletionHandler = completionHandler
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let input = textField.text else {
            return false
        }

        if let output = outputView.text {
            outputView.text = "\(output)\n\(input)"
        }
        textField.text = nil
        
        inputCompletionHandler?(input)

        return true
    }
    
    func onTerminalOutputUpdated(_ update: String?) {
        if let out = outputView.text, let input = update {
            outputView.text = "\(out)\n\(input)"
        }
    }
}

