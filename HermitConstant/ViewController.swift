//
//  ViewController.swift
//  ErmitConstant
//
//  Created by Alex Chekodanov on 18.10.2020.
//  Copyright © 2020 Alex Chekodanov. All rights reserved.
//

import Cocoa
import Surge

class ViewController: NSViewController {
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var dimTextFiled: NSTextField!

    @IBAction func startAction(_ sender: Any) {
        let gradientDecent = GradientDescent(dim: Int(dimTextFiled.intValue))
        if let matrix = gradientDecent.findMatrix(), let det = det(matrix) {
            let dim = gradientDecent.dim
            let matrixMessage = "Matrix \(dim)x\(dim): \n \(matrix.description) \n"
            let detMessage = "Det = \(det) \n"
            appendMessage(matrixMessage + detMessage)
        } else {
            appendMessage("Cannot find matrix")
        }
    }

    func appendMessage(_ message: String) {
        textField.stringValue = message + "\n"
    }
}

