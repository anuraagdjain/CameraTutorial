//
//  ViewController.swift
//  CameraTutorial
//
//  Edited by Anuraag Jain on 7/19/16.
//  Created by Jameson Quave on 9/20/14.
//  Copyright (c) 2014 JQ Software. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var captureButton: UIButton!
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        print("Capture device found")
                        beginSession()
                    }
                }
            }
        }
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    func focusTo(value : Float) {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
                })
                device.unlockForConfiguration()
            } catch {
                //error message
                print("Can't change focus of capture device")
            }
        }
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchPercent = touch.locationInView(self.view).x / screenWidth
            focusTo(Float(touchPercent))
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchPercent = touch.locationInView(self.view).x / screenWidth
            focusTo(Float(touchPercent))
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.focusMode = .Locked
                device.unlockForConfiguration()
            } catch {
                //error message etc.
                print("Capture device not configurable")
            }
        }
        
    }
    
    func beginSession() {
        
        configureDevice()
        do {
            
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            captureSession.sessionPreset = AVCaptureSessionPreset1920x1080
            captureSession.startRunning()
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
        } catch {
            //error message etc.
            print("Capture device not initialisable")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //self.view.layer.addSublayer(previewLayer!)
        self.view.layer.insertSublayer(previewLayer!, below: captureButton.layer)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }
    @IBAction func didTapOnCapture(sender: AnyObject) {
        print("Captured")
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
            }
        }
    }
    
    
}
