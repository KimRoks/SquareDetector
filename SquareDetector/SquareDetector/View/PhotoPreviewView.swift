//
//  PhotoPreviewView.swift
//  SquareDetector
//
//  Created by 김경록 on 2/1/24.
//

import UIKit
import SnapKit

final class PhotoPreviewView: UIView {
    private let photoView: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    private let discardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = UIColor.signatureBlue
        
        return button
    }()
    
    //반시계방향으로 회전시키는 버튼
    private let turncounterclockwiseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("반시계", for: .normal)
        button.tintColor = .black
        
        return button
    }()
    
    private let moveToRepointViewButton: UIButton = {
        let button = UIButton(type: .system)

        button.setImage(UIImage(systemName: "arrow.up.backward.and.arrow.down.forward.square"), for: .normal)
        button.tintColor = UIColor.signatureBlue
        
        return button
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [discardButton,
                                                   turncounterclockwiseButton,
                                                   moveToRepointViewButton
                                                  ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        
        return stack
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
        self.addSubview(photoView)
        self.addSubview(bottomStackView)
        
        photoView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(self.safeAreaLayoutGuide).offset(10)
            make.trailing.equalTo(self.safeAreaLayoutGuide).offset(-10)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-80)
        }
        
        bottomStackView.snp.makeConstraints { make in
            make.top.equalTo(photoView.snp.bottom).offset(20)
            make.leading.equalTo(self.safeAreaLayoutGuide)
            make.trailing.equalTo(self.safeAreaLayoutGuide)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    func updatePhoto(with image: UIImage) {
        photoView.image = image
    }
}

