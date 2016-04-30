//
//  TopView.swift
//  SelfieKit
//
//  Created by Axel Möller on 29/04/16.
//  Copyright © 2016 Budbee AB. All rights reserved.
//

import UIKit

protocol TopViewDelegate: class {
    func flashButtonDidPress(title: String)
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
        button.setImage(self.getImage("AUTO"), forState: .Normal)
        button.setTitle("AUTO", forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0)
        button.setTitleColor(.whiteColor(), forState: .Normal)
        button.setTitleColor(.whiteColor(), forState: .Highlighted)
        button.titleLabel?.font = Configuration.flashButton
        button.addTarget(self, action: #selector(TopView.flashButtonDidPress(_:)), forControlEvents: .TouchUpInside)
        button.contentHorizontalAlignment = .Left
        
        return button
    }()
    
    lazy var rotateCamera: UIButton = { [unowned self] in
        let button = UIButton()
        button.setImage(self.getImage("cameraIcon"), forState: .Normal)
        button.addTarget(self, action: #selector(TopView.rotateCameraButtonDidPress(_:)), forControlEvents: .TouchUpInside)
        button.imageView?.contentMode = .Center
        
        return button
    }()
    
    weak var delegate: TopViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for button in [flashButton, rotateCamera] {
            button.layer.shadowColor = UIColor.blackColor().CGColor
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
    
    func flashButtonDidPress(button: UIButton) {
        currentFlashIndex += 1
        currentFlashIndex = currentFlashIndex % flashButtonTitles.count
        
        switch currentFlashIndex {
        case 1:
            button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.45, alpha: 1), forState: .Normal)
            button.setTitleColor(UIColor(red: 0.52, green: 0.52, blue: 0.24, alpha: 1), forState: .Highlighted)
        default:
            button.setTitleColor(.whiteColor(), forState: .Normal)
            button.setTitleColor(.whiteColor(), forState: .Highlighted)
        }
        
        let newTitle = flashButtonTitles[currentFlashIndex]
        
        button.setImage(getImage(newTitle), forState: .Normal)
        button.setTitle(newTitle, forState: .Normal)
        
        delegate?.flashButtonDidPress(newTitle)
    }
    
    func rotateCameraButtonDidPress(button: UIButton) {
        delegate?.rotateDeviceDidPress()
    }
    
    
    func getImage(name: String) -> UIImage {
        let traitCollection = UITraitCollection(displayScale: 3)
        var bundle = NSBundle(forClass: self.classForCoder)
        
        if let bundlePath = NSBundle(forClass: self.classForCoder).resourcePath?.stringByAppendingString("/SelfieKit.bundle"), resourceBundle = NSBundle(path: bundlePath) {
            bundle = resourceBundle
        }
        
        guard let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: traitCollection) else { return UIImage() }
        
        return image
    }
}