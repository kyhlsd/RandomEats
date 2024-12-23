//
//  SearchMapViewController.swift
//  Data
//
//  Created by 김영훈 on 12/23/24.
//

import UIKit

class SearchMapViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var backButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        return backButton
    }()
    private lazy var closeButton = {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        return closeButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        backButton.addAction(UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)
        
        closeButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        setupUI()
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        if let navigationController = self.navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "PrimaryColor")
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
            
            self.navigationItem.title = "위치 변경"
            let rightButton = UIBarButtonItem(customView: closeButton)
            let leftButton = UIBarButtonItem(customView: backButton)
            self.navigationItem.rightBarButtonItem = rightButton
            self.navigationItem.leftBarButtonItem = leftButton
        }
    }
    
    private func setupUI() {
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            
            
        ])
    }
}
