//
//  ViewController.swift
//  ErmitConstant
//
//  Created by Alex Chekodanov on 18.10.2020.
//  Copyright © 2020 Alex Chekodanov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var textLabel: NSTextField!
    @IBOutlet weak var dimTextFiled: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func startAction(_ sender: Any) {
        let gradientDecent = GradientDescent(dim: Int(dimTextFiled.intValue))
        if let matrix = gradientDecent.findMatrix() {
            let dim = gradientDecent.dim
            textLabel.stringValue = "Matrix \(dim)x\(dim): \n \(matrix.description)"
        } else {
            textLabel.stringValue = "Cannot find matrix"
        }
    }
}

