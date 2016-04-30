//
//  SelfiePickerController2.swift
//  SelfieKit
//
//  Created by Axel Möller on 28/04/16.
//  Copyright © 2016 Budbee AB. All rights reserved.
//

import UIKit
import MediaPlayer

public protocol SelfiePickerDelegate: class {
    func doneButtonDidPress(image: UIImage)
}

public class SelfiePickerController: UIViewController {
    
    struct Dimensions {
        static let bottomContainerHeight: CGFloat = 101
    }
    
    public lazy var bottomContainer: BottomContainerView = { [unowned self] in
        let view = BottomContainerView()
        view.backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)
        view.delegate = self
        
        return view
    }()
    
    lazy var topView: TopView = { [unowned self] in
        let view = TopView()
        view.backgroundColor = .clearColor()
        view.delegate = self
        
        return view
    }()
    
    lazy var cameraController: CameraView = { [unowned self] in
        let controller = CameraView()
        controller.delegate = self
        
        return controller
    }()
    
    lazy var photoView: PhotoView = { [unowned self] in
        let photoView = PhotoView(image: nil)
        photoView.alpha = 0
        
        return photoView
    }()
    
    public weak var delegate: SelfiePickerDelegate?
    var statusBarHidden = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        for subview in [cameraController.view, photoView, bottomContainer, topView] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.backgroundColor = Configuration.mainColor
        
        setupConstraints()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        statusBarHidden = UIApplication.sharedApplication().statusBarHidden
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(statusBarHidden, withAnimation: .Fade)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Actions
    
    func showResult(show: Bool) {
        photoView.alpha = show ? 1 : 0
        topView.flashButton.hidden = show
        topView.rotateCamera.hidden = show
        bottomContainer.doneButton.hidden = !show
        bottomContainer.retakeButton.hidden = !show
        bottomContainer.pickerbutton.enabled = !show
    }
    
}

// MARK: - Bottom Container Delegate

extension SelfiePickerController: BottomContainerViewDelegate {
    func retakeButtonDidPress() {
        photoView.image = nil
        showResult(false)
    }
    
    func doneButtonDidPress() {
        delegate?.doneButtonDidPress(photoView.image!)
    }
    
    func pickerButtonDidPress() {
        cameraController.takePicture()
    }
}

// MARK: - Top View Delegate

extension SelfiePickerController: TopViewDelegate {
    func flashButtonDidPress(title: String) {
        cameraController.flashCamera(title)
    }
    
    func rotateDeviceDidPress() {
        cameraController.rotateCamera()
    }
}

// MARK: - Camera Delegate

extension SelfiePickerController: CameraViewDelegate {
    func didTakeSelfie(image: UIImage) {
        photoView.image = image
        showResult(true)
    }
}