//
//  WebViewController.swift
//  Presentation
//
//  Created by 김영훈 on 12/5/24.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    private lazy var closeButton = {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        return closeButton
    }()
    private lazy var navigationBar = {
        let closeButtonItem = UIBarButtonItem(customView: closeButton)
        let navigationItem = UINavigationItem(title: "식당 정보")
        navigationItem.rightBarButtonItem = closeButtonItem
        let navigationBar = UINavigationBar()
        navigationBar.setItems([navigationItem], animated: true)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.backgroundColor = UIColor(named: "PrimaryColor")
        navigationBar.shadowImage = UIImage()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
    private lazy var webView = {
       let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        closeButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        setupUI()
        
        loadURL()
    }

    private func setupUI() {
        view.addSubview(navigationBar)
        view.addSubview(webView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            webView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            webView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
    
    private func loadURL() {
        guard let url = URL(string: "https://www.google.com/maps/place/%EC%8A%A4%ED%86%A4504/data=!4m7!3m6!1s0x357ca14590a087c1:0xcc6552412013d6d7!4b1!8m2!3d37.4945959!4d126.9577544!16s%2Fg%2F11hzz774k2?entry=ttu&g_ep=EgoyMDI0MTIwMS4xIKXMDSoASAFQAw%3D%3D") else { return }
        webView.load(URLRequest(url: url))
    }
}
