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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        
        setupUI()
        
    }
    
    private func setupUI() {
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            
            
        ])
    }
}
