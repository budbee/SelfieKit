//
//  PhotoView.swift
//  SelfieKit
//
//  Created by Axel Möller on 30/04/16.
//  Copyright © 2016 Budbee AB. All rights reserved.
//

import UIKit

class PhotoView: UIImageView {
    
    override init(image: UIImage?) {
        super.init(image: image)
        contentMode = .scaleAspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
