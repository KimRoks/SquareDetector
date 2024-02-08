//
//  DetectorViewController.swift
//  SquareDetector
//
//  Created by 김경록 on 2/7/24.
//

import UIKit
import CoreImage

final class DetectorViewController: UIViewController {
    
    // MARK: - view life cycle
    private let detectorView = DetectorView()
    private var lastRectangle: CIRectangleFeature?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    override func loadView() {
        self.view = detectorView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        detectorView.delegate = self
        detectorView.cameraView.delegate = self
    }
    
    private func configureNavigation() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "자동/수동", style: .plain, target: self, action: #selector(autoManualButtonTapped))
    }
    
    // MARK: - private methods
    
    @objc
    private func cancelButtonTapped() {
        
    }
    
    @objc
    private func autoManualButtonTapped() {
        
    }
    
    private func showPoints(_ points: [CGPoint], on view: UIView, imageSize: CGSize) {
        DispatchQueue.main.async {
            view.layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }
            
            let path = UIBezierPath()
            
            let convertedPoints = points
            
            guard let firstPoint = convertedPoints.first else { return }
            
            path.move(to: firstPoint)
            
            for pointIndex in 1..<convertedPoints.count {
                path.addLine(to: convertedPoints[pointIndex])
            }
            
            path.close()
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.subBlue.cgColor
            shapeLayer.fillColor = UIColor.signatureBlue.cgColor.copy(alpha: 0.25)
            shapeLayer.lineWidth = 2.0
            
            view.layer.addSublayer(shapeLayer)
        }
    }
}

//MARK: DetectorViewDlegate

extension DetectorViewController: DetectorViewDelegate {
    func shutterATapped() {
        print("dd")
    }
    
    func pushToPreviewView() {
        let photoPreviewView = PhotoPreviewViewController()
        self.navigationController?.pushViewController(photoPreviewView, animated: true)
    }
}

//MARK: CameraViewDelegate

extension DetectorViewController: CameraViewDelegate {
    func cameraView(_ cameraView: CameraView, didDetectRectangles rectangles: [CIRectangleFeature], imageSize: CGSize) {
        DispatchQueue.main.async {
            
            guard !rectangles.isEmpty else {
                self.detectorView.turnOffShutterButton()
                removepreviousRectangle()
                return
            }
            
            let changedRectangles = rectangles.filter { rectangle in
                if let lastRectangle = self.lastRectangle {
                    return self.distanceBetween(lastRectangle, and: rectangle) >= imageSize.width * 0.03
                } else {
                    return true
                }
            }
            
            if !changedRectangles.isEmpty {
                removepreviousRectangle()
                self.detectorView.turnOnShutterButton()
                
                for rectangle in changedRectangles {
                    let points = [self.convertPoint(rectangle.topLeft, view: cameraView, imageSize: imageSize),
                                  self.convertPoint(rectangle.topRight, view: cameraView, imageSize: imageSize),
                                  self.convertPoint(rectangle.bottomRight, view: cameraView, imageSize: imageSize),
                                  self.convertPoint(rectangle.bottomLeft, view: cameraView, imageSize: imageSize)]
                    
                    self.showPoints(points, on: cameraView, imageSize: imageSize)
                    
                    self.lastRectangle = rectangle
                }
            }
        }
        
        func removepreviousRectangle() {
            cameraView.layer.sublayers?.forEach {
                if $0 is CAShapeLayer {
                    $0.removeFromSuperlayer()
                }
            }
        }
    }
    
    func convertPoint(_ point: CGPoint, view: UIView, imageSize: CGSize) -> CGPoint {
        let scaleX = view.frame.width / imageSize.width
        let scaleY = (view.frame.height - view.safeAreaInsets.top) / imageSize.height
        return CGPoint(
            x: point.x * scaleX,
            y: view.frame.height - view.safeAreaInsets.top - (point.y * scaleY)
        )
    }
    
    func drawRectangle(_ rectangle: CIRectangleFeature, on view: UIView, imageSize: CGSize) {
        let points = [self.convertPoint(rectangle.topLeft, view: view, imageSize: imageSize), self.convertPoint(rectangle.topRight, view: view, imageSize: imageSize), self.convertPoint(rectangle.bottomRight, view: view, imageSize: imageSize), self.convertPoint(rectangle.bottomLeft, view: view, imageSize: imageSize)]
        
        self.showPoints(points, on: view, imageSize: imageSize)
    }
    
    func distanceBetween(_ rectangle1: CIRectangleFeature, and rectangle2: CIRectangleFeature) -> CGFloat {
        let dx = rectangle1.bounds.midX - rectangle2.bounds.midX
        let dy = rectangle1.bounds.midY - rectangle2.bounds.midY
        return sqrt(dx * dx + dy * dy)
    }
}
