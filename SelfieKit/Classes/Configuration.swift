//
//  Configuration.swift
//  SelfieKit
//
//  Created by Axel Möller on 28/04/16.
//  Copyright © 2016 Budbee AB. All rights reserved.
//

import UIKit

public struct Configuration {
    
    public static var backgroundColor = UIColor(red: 0.15, green: 0.19, blue: 0.24, alpha: 1)
    public static var mainColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)
    public static var noCameraColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1)
    public static var settingsColor = UIColor.whiteColor()
    
    public static var flashButton = UIFont(name: "HelveticaNeue-Medium", size: 12)!
    public static var retakeButton = UIFont(name: "HelveticaNeue-Medium", size: 19)!
    public static var doneButton = UIFont(name: "HelveticaNeue-Medium", size: 19)!
    public static var noCameraFont = UIFont(name: "HelveticaNeue-Medium", size: 18)!
    public static var settingsFont = UIFont(name: "HelveticaNeue-Medium", size: 18)!
    
    public static var retakeButtonTitle = "Retake"
    public static var doneButtonTitle = "Done"
    public static var noCameraTitle = "Camera is not available"
    public static var settingsTitle = "Settings"
    
}