//
//  ButtonPicker.swift
//  SelfieKit
//
//  Created by Axel Möller on 28/04/16.
//  Copyright © 2016 Budbee AB. All rights reserved.
//

import UIKit

protocol ButtonPickerDelegate: class {
    func buttonDidPress()
}

class ButtonPicker: UIButton {
    
    struct Dimensions {
        static let borderWidth: CGFloat = 2
        static let buttonSize: CGFloat = 58
        static let buttonBorderSize: CGFloat = 68
    }
    
    weak var delegate: ButtonPickerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButton() {
        backgroundColor = .white()
        layer.cornerRadius = Dimensions.buttonSize / 2
        addTarget(self, action: #selector(ButtonPicker.pickerButtonDidPress(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(ButtonPicker.pickerButtonDidHighlight(_:)), for: .touchDown)
    }
    
    func pickerButtonDidPress(_ button: UIButton) {
        backgroundColor = .white()
        delegate?.buttonDidPress()
    }
    
    func pickerButtonDidHighlight(_ button: UIButton) {
        backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
    }
    
}
