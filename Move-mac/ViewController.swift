//
//  ViewController.swift
//  Move-mac
//
//  Created by Samar Sunkaria on 5/27/19.
//  Copyright © 2019 samar. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var textField: NSTextFieldCell!

    var timer: Timer?
    var lastAction: Action?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = #colorLiteral(red: 0.7058823529, green: 0.6431372549, blue: 0.6901960784, alpha: 1)

        view.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(startGame)))
    }

    @objc func startGame() {
        setupGame()
    }

    func setupGame() {
        showNewAction()
        refreshTimer()
    }

    func showNewAction() {
        var newAction = Action.allCases.randomElement()!
        while newAction == lastAction {
            newAction = Action.allCases.randomElement()!
        }

        textField.stringValue = newAction.rawValue.uppercased()
        view.layer?.backgroundColor = newAction.color().cgColor
        lastAction = newAction
    }

    func refreshTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (_) in
            self.showNewAction()
        })
    }

}

