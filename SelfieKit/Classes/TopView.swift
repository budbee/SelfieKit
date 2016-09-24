//
//  TopView.swift
//  SelfieKit
//
//  Created by Axel Möller on 29/04/16.
//  Copyright © 2016 Budbee AB. All rights reserved.
//

import UIKit

protocol TopViewDelegate: class {
    func flashButtonDidPress(_ title: String)
    func rotateDeviceDidPress()
}

class TopView: UIView {
    
    struct Dimensions {
        static let leftOffset: CGFloat = 11
        static let rightOffset: CGFloat = 7
        static let height: CGFloat = 34
    }
    
    var currentFlashIndex = 0
    let flashButtonTitles = ["AUTO", "ON", "OFF"]
    
    lazy var flashButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setImage(self.getImage("AUTO"), for: UIControlState())
        button.setTitle("AUTO", for: UIControlState())
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0)
        button.setTitleColor(.white, for: UIControlState())
        button.setTitleColor(.white, for: .highlighted)
        button.titleLabel?.font = Configuration.flashButton
        button.addTarget(self, action: #selector(TopView.flashButtonDidPress(_:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        
        return button
    }()
    
    lazy var rotateCamera: UIButton = { [unowned self] in
        let button = UIButton()
        button.setImage(self.getImage("cameraIcon"), for: UIControlState())
        button.addTarget(self, action: #selector(TopView.rotateCameraButtonDidPress(_:)), for: .touchUpInside)
        button.imageView?.contentMode = .center
        
        return button
    }()
    
    weak var delegate: TopViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for button in [flashButton, rotateCamera] {
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.5
            button.layer.shadowOffset = CGSize(width: 0, height: 1)
            button.layer.shadowRadius = 1
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
        }
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func flashButtonDidPress(_ button: UIButton) {
        currentFlashIndex += 1
        currentFlashIndex = currentFlashIndex % flashButtonTitles.count
        
        switch currentFlashIndex {
        case 1:
            button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.45, alpha: 1), for: UIControlState())
            button.setTitleColor(UIColor(red: 0.52, green: 0.52, blue: 0.24, alpha: 1), for: .highlighted)
        default:
            button.setTitleColor(.white, for: UIControlState())
            button.setTitleColor(.white, for: .highlighted)
        }
        
        let newTitle = flashButtonTitles[currentFlashIndex]
        
        button.setImage(getImage(newTitle), for: UIControlState())
        button.setTitle(newTitle, for: UIControlState())
        
        delegate?.flashButtonDidPress(newTitle)
    }
    
    func rotateCameraButtonDidPress(_ button: UIButton) {
        delegate?.rotateDeviceDidPress()
    }
    
    
    func getImage(_ name: String) -> UIImage {
        let traitCollection = UITraitCollection(displayScale: 3)
        var bundle = Bundle(for: self.classForCoder)
        
        let bundlePath = (Bundle(for: self.classForCoder).resourcePath)! + "/SelfieKit.bundle"
        let resourceBundle = Bundle(path: bundlePath)
        if nil != resourceBundle {
            bundle = resourceBundle!
        }
        
        guard let image = UIImage(named: name, in: bundle, compatibleWith: traitCollection) else { return UIImage() }
        
        return image
    }
}
