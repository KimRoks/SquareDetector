//
//  CameraView.swift
//  SquareDetector
//
//  Created by 김경록 on 2/7/24.
//

import UIKit
import AVFoundation
import CoreImage

protocol CameraViewDelegate: AnyObject {
    func cameraView(_ cameraView: CameraView, didDetectRectangles rectangles: [CIRectangleFeature], imageSize: CGSize)
    func cameraView(_ cameraView: CameraView, capturedImage: UIImage)
}

final class CameraView: UIView, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    weak var delegate: CameraViewDelegate?
    
    //MARK: properties
    
    private var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var output: AVCaptureVideoDataOutput?
    private var photoOutput = AVCapturePhotoOutput()
    
    //MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSession()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSession()
    }
    
    //MARK: private method
    
    private func setupSession() {
        session = AVCaptureSession()
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if session?.canAddInput(input) == true {
            session?.addInput(input)
        }
        
        if session?.canAddOutput(photoOutput) == true {
            session?.addOutput(photoOutput)
        }
        
        output = AVCaptureVideoDataOutput()
        output?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "image_processing_queue"))
        if let output = output, session?.canAddOutput(output) == true {
            session?.addOutput(output)
        }
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let orientation = windowScene.interfaceOrientation
                self.output?.connection(with: .video)?.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session!)
                self.previewLayer?.videoGravity = .resizeAspectFill
                self.previewLayer?.frame = self.bounds
                self.layer.addSublayer(self.previewLayer!)
            }
        }
        
        DispatchQueue.global().async {
            self.session?.startRunning()
        }
    }
    
    private func detectRectangle(in image: CIImage) {
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let rectangles = detector?.features(in: image) as? [CIRectangleFeature]
        
        delegate?.cameraView(self, didDetectRectangles: rectangles ?? [], imageSize: image.extent.size)
    }
    
    //MARK: internal method
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer)
        detectRectangle(in: cameraImage)
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Failed to process photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        delegate?.cameraView(self, capturedImage: image)
    }
}
