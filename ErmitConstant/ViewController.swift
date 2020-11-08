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
    @IBOutlet weak var textView: NSScrollView!
    var gradientDecent: GradientDescent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientDecent = GradientDescent(dim: 2)
        // Do any additional setup after loading the view.
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBAction func startAction(_ sender: Any) {
        if let matrix = gradientDecent?.findMatrix() {
            debugPrint("Matrix: \n \(matrix.description)")
        } else {
            debugPrint("Cannot find matrix")
        }
    }
}

