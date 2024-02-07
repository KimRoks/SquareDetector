//
//  DetectorViewController.swift
//  SquareDetector
//
//  Created by 김경록 on 2/7/24.
//

import UIKit

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
}

extension DetectorViewController: PreviewMoveable {
    func pushToPreviewView() {
        let photoPreviewView = PhotoPreviewViewController()
        self.navigationController?.pushViewController(photoPreviewView, animated: true)
    }
}
