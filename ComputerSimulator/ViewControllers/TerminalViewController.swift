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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        terminalInputView.becomeFirstResponder()
        terminalInputView.tintColor = #colorLiteral(red: 0.4234788418, green: 0.8100475669, blue: 0.4512391686, alpha: 1)
        terminalInputView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        return true
    }
    
}

