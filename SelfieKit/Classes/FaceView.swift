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
        backgroundColor = .clear
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
        let attributes: [NSLayoutAttribute] = [.centerX, .centerY, .width, .height]
        
        for attribute in attributes {
            addConstraint(NSLayoutConstraint(item: ellipseView, attribute: attribute, relatedBy: .equal, toItem: self, attribute: attribute, multiplier: 1, constant: 0))
        }
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
