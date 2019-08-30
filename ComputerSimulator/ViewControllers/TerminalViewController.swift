//
//  TerminalViewController.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import UIKit

class TerminalViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var outputView: UILabel!
    @IBOutlet weak var terminalInputView: UITextField!

    var viewModel: TerminalViewModel?
    private var inputCompletionHandler: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        viewModel?.terminalOutputUpdated = updateOutputView
        viewModel?.showPrompt = showPrompt(message:completionHandler:)
        initTerminalViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showPrompt(message: viewModel?.mainPrompt, completionHandler: viewModel?.terminalInputReceived)
    }
    
        
    func showPrompt(message: String?, completionHandler: ((String) -> Void)?) {
        viewModel?.outputText = message
        inputCompletionHandler = completionHandler
    }
    
    private func initTerminalViews() {
        terminalInputView.becomeFirstResponder()
        terminalInputView.tintColor = #colorLiteral(red: 0.4234788418, green: 0.8100475669, blue: 0.4512391686, alpha: 1)
        terminalInputView.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let input = textField.text else {
            return false
        }

        viewModel?.outputText = input
        textField.text = nil
        inputCompletionHandler?(input)

        return true
    }
    
    private func updateOutputView(with text: String) {
        outputView.text = text
    }
}

