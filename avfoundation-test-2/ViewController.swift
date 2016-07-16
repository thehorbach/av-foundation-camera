//
//  ViewController.swift
//  avfoundation-test-2
//
//  Created by Vyacheslav Horbach on 14/07/16.
//  Copyright © 2016 Vyacheslav Horbach. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var previewView: UIView!

    var captureSession = AVCaptureSession()
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devices()
        
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.position == AVCaptureDevicePosition.Back {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        beginSession()
                    }
                }
            }
        }
    }

    func beginSession() {
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(deviceInput)
            
            if (captureSession.canAddInput(deviceInput) == true) {
                captureSession.addInput(deviceInput)
            }
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            captureSession.addOutput(stillImageOutput)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewView.layer.addSublayer(previewLayer!)
            
            previewLayer?.frame = previewView.bounds
            
            captureSession.startRunning()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        
        
    }


    @IBAction func didPressTakePhoto(sender: UIButton) {
        
        toggleFlash()
        
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) {
            
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProviderCreateWithCFData(imageData)
                
                let en = CGColorRenderingIntent.RenderingIntentDefault
                let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, en)
                
                let ri = UIImageOrientation.Right
                let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: ri)
                
                self.capturedImage.image = image
            })
        }
        
        var timer = NSTimer()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.toggleFlash), userInfo: nil, repeats: false)
        
       // toggleFlash()

    }
    
    func toggleFlash() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                } else {
                    do {
                        try device.setTorchModeOnWithLevel(1.0)
                    } catch {
                        print(error)
                    }
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
}











