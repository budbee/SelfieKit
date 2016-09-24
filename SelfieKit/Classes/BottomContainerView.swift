//
//  BottomContainerView.swift
//  SelfieKit
//
//  Created by Axel Möller on 28/04/16.
//  Copyright © 2016 Budbee AB. All rights reserved.
//

import UIKit

protocol BottomContainerViewDelegate: class {
    func pickerButtonDidPress()
    func retakeButtonDidPress()
    func doneButtonDidPress()
}

open class BottomContainerView: UIView {
    
    lazy var pickerbutton: ButtonPicker = { [unowned self] in
        let pickerButton = ButtonPicker()
        pickerButton.delegate = self
        
        return pickerButton
    }()
    
    lazy var borderPickerButton: UIView = {
        let view = UIView()
        view.backgroundColor = .clear()
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = ButtonPicker.Dimensions.borderWidth
        view.layer.cornerRadius = ButtonPicker.Dimensions.buttonBorderSize / 2
        
        return view
    }()
    
    open lazy var retakeButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle(Configuration.retakeButtonTitle, for: UIControlState())
        button.titleLabel?.font = Configuration.retakeButton
        button.addTarget(self, action: #selector(BottomContainerView.retakeButtonDidPress(_:)), for: .touchUpInside)
        button.isHidden = true
        
        return button
    }()
    
    open lazy var doneButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle(Configuration.doneButtonTitle, for: UIControlState())
        button.titleLabel?.font = Configuration.doneButton
        button.addTarget(self, action: #selector(BottomContainerView.doneButtonDidPress(_:)), for: .touchUpInside)
        button.isHidden = true
        
        return button
    }()
    
    lazy var topSeparator: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = Configuration.backgroundColor
        
        return view
    }()
    
    weak var delegate: BottomContainerViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        [borderPickerButton, pickerbutton, retakeButton, doneButton, topSeparator].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        backgroundColor = Configuration.backgroundColor
        
        setupConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func retakeButtonDidPress(_ button: UIButton) {
        delegate?.retakeButtonDidPress()
    }
    
    func doneButtonDidPress(_ button: UIButton) {
        delegate?.doneButtonDidPress()
    }
}

extension BottomContainerView: ButtonPickerDelegate {
    func buttonDidPress() {
        delegate?.pickerButtonDidPress()
    }
}
