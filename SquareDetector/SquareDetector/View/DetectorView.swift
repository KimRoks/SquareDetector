//
//  DetectorView.swift
//  SquareDetector
//
//  Created by 김경록 on 2/7/24.
//

import UIKit
import SnapKit

protocol DetectorViewDelegate: AnyObject {
    func pushToPreviewView()
    func shutterATapped()
}

final class DetectorView: UIView {
    weak var delegate: DetectorViewDelegate?
    
    // MARK: - properties
    
    let cameraView: CameraView = {
        let view = CameraView()

        return view
    }()
    
    private lazy var movePhotoPreviewButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .cyan
        button.addTarget(self, action: #selector(previewImageTapped), for: .touchUpInside)
        
        return button
    }()

    private lazy var shutterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "camera.aperture"), for: .normal)
        button.tintColor = .systemGray
        button.isEnabled = false
        button.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.tintColor = .black
        
        return button
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private methods
    
    private func configureLayout() {
        self.addSubview(cameraView)
        self.addSubview(movePhotoPreviewButton)
        self.addSubview(shutterButton)
        self.addSubview(saveButton)
        
        cameraView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(self.safeAreaLayoutGuide)
            make.trailing.equalTo(self.safeAreaLayoutGuide)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-80)
        }
        
        movePhotoPreviewButton.snp.makeConstraints { make in
            make.top.equalTo(cameraView.snp.bottom).offset(20)
            make.leading.equalTo(self.safeAreaLayoutGuide).offset(15)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.width.equalTo(self.snp.width).multipliedBy(0.15)
        }
  
        shutterButton.snp.makeConstraints { make in
            make.top.equalTo(cameraView.snp.bottom).offset(20)
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.width.equalTo(self.snp.width).multipliedBy(0.15)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(cameraView.snp.bottom).offset(20)
            make.trailing.equalTo(self.safeAreaLayoutGuide).offset(-15)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.width.equalTo(self.snp.width).multipliedBy(0.15)
        }
    }
    
    @objc
    private func previewImageTapped() {
        delegate?.pushToPreviewView()
    }
    
    @objc
    private func shutterButtonTapped() {
        delegate?.shutterATapped()
    }
    
    //MARK: internal method
    
    func turnOnShutterButton() {
        shutterButton.isEnabled = true
    }
    
    func turnOffShutterButton() {
        shutterButton.isEnabled = false
    }
}
