//
//  TerminalViewController.swift
//  ComputerSimulator
//
//  Created by Rizianne Veluz on 26/08/2019.
//  Copyright © 2019 Rizianne Veluz. All rights reserved.
//

import UIKit

class TerminalViewController: UIViewController {
    
    /// Displays the terminal's text history
    @IBOutlet weak var terminalOutputView: UILabel!
    /// Receives the user's input
    @IBOutlet weak var terminalInputView: UITextField!
    /// Houses the terminal's input and output views
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// The view model that drives the terminal's content and facilitates communication with the parser
    var viewModel: TerminalViewModel?
    /// Stores the corresponding view model callback function to be called when the user sends input via the terminal
    private var inputCompletionHandler: ((String) -> Void)?
    
    // MARK: - Life Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set up handlers for the view model's notifications
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
            // Scroll to the bottom of the view to ensure that the latest text output is visible
            self?.view.layoutIfNeeded()
            self?.scrollToBottom()
        }
        
        viewModel?.startUp()
        terminalInputView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        subscribeToKeyboardNotifications()
        // Show the keyboard right away
        terminalInputView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - Private Functions
    /**
     Sets the corresponding view model callback function to be called when the user sends input via the terminal
     */
    private func receiveUserInput(completionHandler: ((String) -> Void)?) {
        inputCompletionHandler = completionHandler
    }
    
    /**
     Scrolls to the bottom of the main scroll view
     */
    private func scrollToBottom() {
        // TODO: Adjust scroll when device changes orientation
        
        if (scrollView.contentSize.height + scrollView.contentInset.bottom < scrollView.bounds.height) {
            return
        }
        
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height)
        
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    /**
     Subscribes to notifications for when keyboard is shown or hidden
     */
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /**
     Removes the subscriptions for keyboard notifications
     */
    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    /**
     Adjusts the main scroll view to keep the terminal's contents visible when the keyboard is shown
     */
    @objc private func keyboardWillShow(notif: NSNotification) {
        guard let userInfo = notif.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        scrollView.contentInset.bottom = self.view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    /**
     Adjusts the main scroll view when the keyboard is hidden
     */
    @objc private func keyboardWillHide(notif: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
}

// MARK: - UITextFieldDelegate Delegate Functions Implementation
extension TerminalViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let input = textField.text else {
            return false
        }
        
        // reset the text field then notify the view model of the user's input
        textField.text = nil
        inputCompletionHandler?(input)
        
        return true
    }
}
