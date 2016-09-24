//
//  CameraView.swift
//  SelfieKit
//
//  Created by Axel Möller on 28/04/16.
//  Copyright © 2016 Budbee AB. All rights reserved.
//

import UIKit
import AVFoundation
import PhotosUI
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol CameraViewDelegate: class {
    func didTakeSelfie(_ image: UIImage)
}

class CameraView: UIViewController {
    
    lazy var blurView: UIVisualEffectView = { [unowned self] in
        let effect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: effect)
        
        return blurView
    }()
    
    lazy var focusImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView()
        imageView.image = self.getImage("focusIcon")
        imageView.backgroundColor = .clear()
        imageView.frame = CGRect(x: 0, y: 0, width: 110, height: 110)
        imageView.alpha = 0
        
        return imageView
    }()
    
    lazy var faceOverlayView: FaceView = { [unowned self] in
        let view = FaceView()
        
        return view
    }()
    
    lazy var capturedImageView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = .black()
        view.alpha = 0
        
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.alpha = 0
        
        return view
    }()
    
    lazy var noCameraLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = Configuration.noCameraFont
        label.textColor = Configuration.noCameraColor
        label.text = Configuration.noCameraTitle
        label.sizeToFit()
        
        return label
    }()
    
    
    lazy var noCameraButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: Configuration.settingsTitle,
                                       attributes: [
                                        NSFontAttributeName: Configuration.settingsFont,
                                        NSForegroundColorAttributeName: Configuration.settingsColor,
            ])
        
        button.setAttributedTitle(title, for: UIControlState())
        button.sizeToFit()
        button.addTarget(self, action: #selector(CameraView.settingsButtonDidTap), for: .touchUpInside)
        
        return button
    }()
    
    let captureSession = AVCaptureSession()
    var devices = AVCaptureDevice.devices()
    var captureDevice: AVCaptureDevice?
    var captureDevices: NSMutableArray?
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: CameraViewDelegate?
    var stillImageOutput: AVCaptureStillImageOutput?
    var animationTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeCamera()
        
        view.backgroundColor = Configuration.mainColor
        previewLayer?.backgroundColor = Configuration.mainColor.cgColor
        
        containerView.addSubview(blurView)
        [focusImageView, faceOverlayView, capturedImageView].forEach {
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setCorrectOrientationToPreviewLayer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        previewLayer?.frame.size = size
        setCorrectOrientationToPreviewLayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let centerX = view.bounds.width / 2
        
        noCameraLabel.center = CGPoint(x: centerX, y: view.bounds.height / 2 - 50)
        noCameraButton.center = CGPoint(x: centerX, y: noCameraLabel.frame.maxY + 40)
        
        [noCameraLabel, noCameraButton].forEach {
            view.bringSubview(toFront: $0)
        }
    }
    
    func initializeCamera() {
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        captureDevices = NSMutableArray()
        
        showNoCamera(false)
        
        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if (devices?.isEmpty)! { devices = AVCaptureDevice.devices() }
        
        for device in devices! {
            if let device = device as? AVCaptureDevice , device.hasMediaType(AVMediaTypeVideo) {
                if authorizationStatus == .authorized {
                    captureDevice = device
                    captureDevices?.add(device)
                } else if authorizationStatus == .notDetermined {
                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                        if granted {
                            self.captureDevice = device
                            self.captureDevices?.add(device)
                        }
                        self.showNoCamera(!granted)
                    })
                } else {
                    showNoCamera(true)
                }
            }
        }
        
        for device in devices! {
            if let device = device as? AVCaptureDevice , device.hasMediaType(AVMediaTypeVideo) {
                if device.position == .front {
                    captureDevice = device
                    break
                }
            }
        }
        if captureDevice == nil {
            captureDevice = captureDevices?.firstObject as? AVCaptureDevice
        }
        
        if captureDevices != nil { beginSession() }
    }
    
    // MARK: - Actions
    
    func settingsButtonDidTap() {
        DispatchQueue.main.async { 
            if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(settingsURL)
            }
        }
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
            } catch _ {
                print("Couldn't lock configuration")
            }
            device.unlockForConfiguration()
        }
    }
    
    func beginSession() {
        configureDevice()
        guard captureSession.inputs.count == 0 else { return }
        
        let captureDeviceInput: AVCaptureDeviceInput?
        do { try
            captureDeviceInput = AVCaptureDeviceInput(device: self.captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print("Failed to capture device")
        }
        
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else { return }
        self.previewLayer = previewLayer
        previewLayer.autoreverses = true
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.layer.frame
        view.clipsToBounds = true
        captureSession.startRunning()
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession.addOutput(stillImageOutput)
    }
    
    func showNoCamera(_ show: Bool) {
        [noCameraButton, noCameraLabel].forEach {
            show ? view.addSubview($0) : $0.removeFromSuperview()
        }
    }
    
    func rotateCamera() {
        guard let captureDevice = captureDevice,
            let currentDeviceInput = captureSession.inputs.first as? AVCaptureDeviceInput,
            let deviceIndex = captureDevices?.index(of: captureDevice) else { return }
        
        var newDeviceIndex = 0
        
        blurView.frame = view.bounds
        containerView.frame = view.bounds
        view.addSubview(containerView)
        
        if let index = captureDevices?.count , deviceIndex != index - 1 && deviceIndex < captureDevices?.count {
            newDeviceIndex = deviceIndex + 1
        }
        
        self.captureDevice = captureDevices?.object(at: newDeviceIndex) as? AVCaptureDevice
        configureDevice()
        
        guard let currentCaptureDevice = self.captureDevice else { return }
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            self.containerView.alpha = 1
            }, completion: { fisished in
                self.captureSession.beginConfiguration()
                self.captureSession.removeInput(currentDeviceInput)
                
                self.captureSession.sessionPreset = currentCaptureDevice.supportsAVCaptureSessionPreset(AVCaptureSessionPreset1280x720)
                ? AVCaptureSessionPreset1280x720
                : AVCaptureSessionPreset640x480
                
                do { try
                    self.captureSession.addInput(AVCaptureDeviceInput(device: self.captureDevice))
                } catch {
                    print("There was an error capturing your device.")
                }
                
                self.captureSession.commitConfiguration()
                UIView.animate(withDuration: 0.7, animations: { [unowned self] in
                    self.containerView.alpha = 0
                })
        })
    }
    
    func flashCamera(_ title: String) {
        
        do {
            try captureDevice?.lockForConfiguration()
        } catch _ { }
        
        switch title {
        case "ON":
            captureDevice?.flashMode = .on
        case "OFF":
            captureDevice?.flashMode = .off
        default:
            captureDevice?.flashMode = .auto
        }
    }
    
    func takePicture() {
        capturedImageView.frame = view.bounds
        
        UIView.animate(withDuration: 0.1, animations: { 
            self.capturedImageView.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: { 
                    self.capturedImageView.alpha = 0
                    })
        })
        
        let queue = DispatchQueue(label: "session queue", attributes: [])
        
        guard let stillImageOutput = self.stillImageOutput else { return }
        
        if let videoOrientation = previewLayer?.connection.videoOrientation {
            stillImageOutput.connection(withMediaType: AVMediaTypeVideo).videoOrientation = videoOrientation
        }
        
        queue.async(execute: { [unowned self] in
            stillImageOutput.captureStillImageAsynchronously(from: stillImageOutput.connection(withMediaType: AVMediaTypeVideo), completionHandler: { (buffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                
                guard let imageFromData = UIImage(data: imageData!) else { return }
                
                self.delegate?.didTakeSelfie(imageFromData)
                
            })
        })
    }
    
    func timerDidFire() {
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            self.focusImageView.alpha = 0
        }, completion: { _ in
            self.focusImageView.transform = CGAffineTransform.identity
        }) 
    }
    
    func focusTo(_ point: CGPoint) {
        guard let device = captureDevice else { return }
        do { try device.lockForConfiguration() } catch {
            print("Couldn't lock configuration")
        }
        
        if device.isFocusModeSupported(AVCaptureFocusMode.locked) {
            device.focusPointOfInterest = CGPoint(x: point.x / UIScreen.main.bounds.width, y: point.y / UIScreen.main.bounds.height)
            device.unlockForConfiguration()
            focusImageView.center = point
            UIView.animate(withDuration: 0.5, animations: { [unowned self] in
                self.focusImageView.alpha = 1
                self.focusImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                }, completion: { _ in
                    self.animationTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                        selector: #selector(CameraView.timerDidFire), userInfo: nil, repeats: false)
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        let anyTouch = firstTouch
        let touchX = anyTouch.location(in: view).x
        let touchY = anyTouch.location(in: view).y
        focusImageView.transform = CGAffineTransform.identity
        animationTimer?.invalidate()
        focusTo(CGPoint(x: touchX, y: touchY))
    }
    
    func getImage(_ name: String) -> UIImage {
        let traitCollection = UITraitCollection(displayScale: 3)
        var bundle = Bundle(for: self.classForCoder)
        
        if let bundlePath = (Bundle(for: self.classForCoder).resourcePath)! + "/SelfiePicker.bundle", let resourceBundle = Bundle(path: bundlePath) {
            bundle = resourceBundle
        }
        
        guard let image = UIImage(named: name, in: bundle, compatibleWith: traitCollection) else { return UIImage() }
        
        return image
    }
    
    func setCorrectOrientationToPreviewLayer() {
        guard let previewLayer = self.previewLayer,
            let connection = previewLayer.connection
            else { return }
        
        switch UIDevice.current.orientation {
        case .portrait:
            connection.videoOrientation = .portrait
        case .landscapeLeft:
            connection.videoOrientation = .landscapeRight
        case .landscapeRight:
            connection.videoOrientation = .landscapeLeft
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        default:
            break
        }
    }
    
}
