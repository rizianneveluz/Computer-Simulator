//
//  TerminalViewController.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import UIKit

class TerminalViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var terminalOutputView: UILabel!
    @IBOutlet weak var terminalInputView: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var viewModel: TerminalViewModel?
    private var inputCompletionHandler: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        viewModel?.showMenuPrompt = { [weak self] in
            self?.receiveUserInput(completionHandler: { choice in
                self?.viewModel?.didReceiveMenuInput(choice: choice)
            })
        }
        
        viewModel?.showCommandPrompt = { [weak self] in
            self?.receiveUserInput(completionHandler: { command in
                self?.viewModel?.didReceiveCommandInput(command: command)
            })
        }
        
        viewModel?.didUpdateHistory = { [weak self] in
            self?.terminalOutputView.text = self?.viewModel?.history
        }
        
        viewModel?.didStartUp()
        terminalInputView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        subscribeToKeyboardNotifications()
        terminalInputView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
        
    func receiveUserInput(completionHandler: ((String) -> Void)?) {
        inputCompletionHandler = completionHandler
    }
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notif: NSNotification) {
        guard let userInfo = notif.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        scrollView.contentInset.bottom = self.view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc private func keyboardWillHide(notif: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let input = textField.text else {
            return false
        }

        textField.text = nil
        inputCompletionHandler?(input)

        return true
    }
}

