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

extension DetectorViewController: PreviewMoveable {
    func pushToPreviewView() {
        let photoPreviewView = PhotoPreviewViewController()
        self.navigationController?.pushViewController(photoPreviewView, animated: true)
    }
}

extension DetectorViewController: CameraViewDelegate {
    func cameraView(_ cameraView: CameraView, didDetectRectangles rectangles: [CIRectangleFeature], imageSize: CGSize) {
        DispatchQueue.main.async {
            cameraView.layer.sublayers?.forEach { if $0 is CAShapeLayer { $0.removeFromSuperlayer() } }
            
            guard !rectangles.isEmpty else {
                print("사각형이 없음")
                return
            }
            
            for rectangle in rectangles {
                let points = [self.convertPoint(rectangle.topLeft, view: cameraView, imageSize: imageSize), self.convertPoint(rectangle.topRight, view: cameraView, imageSize: imageSize), self.convertPoint(rectangle.bottomRight, view: cameraView, imageSize: imageSize), self.convertPoint(rectangle.bottomLeft, view: cameraView, imageSize: imageSize)]
                
                
                self.showPoints(points, on: cameraView, imageSize: imageSize)
                
                print("사각형을 찾았습니다 \(rectangle.bounds)")
            }
        }
    }
    
    func convertPoint(_ point: CGPoint, view: UIView, imageSize: CGSize) -> CGPoint {
        let scaleX = view.frame.width / imageSize.width
        let scaleY = (view.frame.height - view.safeAreaInsets.top) / imageSize.height
        return CGPoint(
            x: point.x * scaleX,
            y: view.frame.height - view.safeAreaInsets.top - (point.y * scaleY) // 네비게이션 컨트롤러의 높이를 고려합니다.
        )
    }
    
    func drawRectangle(_ rectangle: CIRectangleFeature, on view: UIView, imageSize: CGSize) {
        let points = [self.convertPoint(rectangle.topLeft, view: view, imageSize: imageSize), self.convertPoint(rectangle.topRight, view: view, imageSize: imageSize), self.convertPoint(rectangle.bottomRight, view: view, imageSize: imageSize), self.convertPoint(rectangle.bottomLeft, view: view, imageSize: imageSize)]
        
        self.showPoints(points, on: view, imageSize: imageSize)
    }
}

