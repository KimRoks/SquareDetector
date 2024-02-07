//
//  PhotoPreviewViewController.swift
//  SquareDetector
//
//  Created by 김경록 on 2/1/24.
//

import UIKit

class PhotoPreviewViewController: UIViewController {

    let pageLabel: UILabel = {
        let label = UILabel()
        
        label.text = "1/6"
        label.textColor = .white
        
        return label
    }()
    
    // MARK: - view life cycle

    override func loadView() {
        self.view = PhotoPreviewView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func configureNavigation() {
        self.navigationController?.navigationBar.backgroundColor = UIColor.signatureBlue
        self.navigationItem.titleView = pageLabel
    }
}
