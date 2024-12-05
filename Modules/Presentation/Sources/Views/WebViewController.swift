//
//  WebViewController.swift
//  Presentation
//
//  Created by 김영훈 on 12/5/24.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
//    private lazy var navigationBar = {
//        let navItem = UINavigationItem(title: "식당 정보")
//    }()
    
//    private lazy var closeButton = {
//        let closeButton = UIButton()
//        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
//        closeButton.tintColor = .black
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        return closeButton
//    }
    
    private lazy var webView = {
       let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        setupUI()
        loadURL()
    }

    private func setupUI() {
        view.addSubview(webView)
//        view.addSubview(closeButton)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            webView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
    
    private func loadURL() {
        if let url = URL(string: "https://www.google.com/maps/place/%EC%8A%A4%ED%86%A4504/data=!4m7!3m6!1s0x357ca14590a087c1:0xcc6552412013d6d7!4b1!8m2!3d37.4945959!4d126.9577544!16s%2Fg%2F11hzz774k2?entry=ttu&g_ep=EgoyMDI0MTIwMS4xIKXMDSoASAFQAw%3D%3D") {
            webView.load(URLRequest(url: url))
        }
    }
}
