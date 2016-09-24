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
    func doneButtonDidPress(_ image: UIImage)
}

open class SelfiePickerController: UIViewController {
    
    struct Dimensions {
        static let bottomContainerHeight: CGFloat = 101
    }
    
    open lazy var bottomContainer: BottomContainerView = { [unowned self] in
        let view = BottomContainerView()
        view.backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)
        view.delegate = self
        
        return view
    }()
    
    lazy var topView: TopView = { [unowned self] in
        let view = TopView()
        view.backgroundColor = .clear()
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
    
    open weak var delegate: SelfiePickerDelegate?
    var statusBarHidden = true
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        for subview in [cameraController.view, photoView, bottomContainer, topView] {
            view.addSubview(subview!)
            subview?.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.backgroundColor = Configuration.mainColor
        
        setupConstraints()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarHidden = UIApplication.shared.isStatusBarHidden
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarHidden(statusBarHidden, with: .fade)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    open override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - Actions
    
    func showResult(_ show: Bool) {
        photoView.alpha = show ? 1 : 0
        topView.flashButton.isHidden = show
        topView.rotateCamera.isHidden = show
        bottomContainer.doneButton.isHidden = !show
        bottomContainer.retakeButton.isHidden = !show
        bottomContainer.pickerbutton.isEnabled = !show
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
    func flashButtonDidPress(_ title: String) {
        cameraController.flashCamera(title)
    }
    
    func rotateDeviceDidPress() {
        cameraController.rotateCamera()
    }
}

// MARK: - Camera Delegate

extension SelfiePickerController: CameraViewDelegate {
    func didTakeSelfie(_ image: UIImage) {
        photoView.image = image
        showResult(true)
    }
}
