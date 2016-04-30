//
//  FaceView.swift
//  SelfieKit
//
//  Created by Axel Möller on 29/04/16.
//  Copyright © 2016 Budbee AB. All rights reserved.
//

import UIKit

class FaceView: UIView {
    
    lazy var ellipseView: UIImageView = { [unowned self] in
        let ellipseView = UIImageView()
        ellipseView.image = self.getImage("faceOverlay")
        ellipseView.translatesAutoresizingMaskIntoConstraints = false
        
        return ellipseView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clearColor()
        translatesAutoresizingMaskIntoConstraints = false
        
        [ellipseView].forEach {
            addSubview($0)
        }
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        let attributes: [NSLayoutAttribute] = [.CenterX, .CenterY, .Width, .Height]
        
        for attribute in attributes {
            addConstraint(NSLayoutConstraint(item: ellipseView, attribute: attribute, relatedBy: .Equal, toItem: self, attribute: attribute, multiplier: 1, constant: 0))
        }
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
