//
//  ViewController.swift
//  SelfieKit
//
//  Created by Axel Möller on 04/28/2016.
//  Copyright (c) 2016 Axel Möller. All rights reserved.
//

import UIKit
import SelfieKit

class ViewController: UIViewController, SelfiePickerDelegate {
    
    var selfiePicker: SelfiePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        selfiePicker = SelfiePickerController()
        selfiePicker?.delegate = self
        present(selfiePicker!, animated: true, completion: nil)
        
    }
    
    func doneButtonDidPress(_ image: UIImage) {
        print("Took a selfie: ", image)
        selfiePicker?.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

