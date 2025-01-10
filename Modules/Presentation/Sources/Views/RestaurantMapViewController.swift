//
//  RestaurantMapViewController.swift
//  Presentation
//
//  Created by 김영훈 on 12/5/24.
//

import UIKit
import MapKit

public class RestaurantMapViewController: UIViewController {
    private let allowedDistances = [100, 200, 300, 400, 500]
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    private lazy var placeContainer = {
        let placeContainer = UIView()
        placeContainer.layer.cornerRadius = 10
        placeContainer.layer.masksToBounds = true
        placeContainer.backgroundColor = UIColor(named: "SecondaryColor")
        placeContainer.translatesAutoresizingMaskIntoConstraints = false
        return placeContainer
    }()
    private lazy var placeSettingLabel = {
        let placeSettingLabel = UILabel()
        placeSettingLabel.text = "위치 설정"
        placeSettingLabel.textColor = .black
        placeSettingLabel.font = .systemFont(ofSize: 14, weight: .medium)
        placeSettingLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeSettingLabel
    }()
    private lazy var currentLocationButton = {
        let currentLocationButton = UIButton()
        currentLocationButton.setTitle("현재 위치로", for: .normal)
        currentLocationButton.setTitleColor(.systemBlue, for: .normal)
        currentLocationButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        return currentLocationButton
    }()
    private let separatorLine: UIView = {
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor(named: "ContrastColor")
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        return separatorLine
    }()
    private lazy var searchButton = {
        let searchButton = UIButton()
        searchButton.setImage(UIImage(systemName: "location.magnifyingglass"), for: .normal)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        return searchButton
    }()
    private lazy var distanceContainer = {
        let distanceContainer = UIView()
        distanceContainer.layer.cornerRadius = 10
        distanceContainer.layer.masksToBounds = true
        distanceContainer.backgroundColor = UIColor(named: "SecondaryColor")
        distanceContainer.translatesAutoresizingMaskIntoConstraints = false
        return distanceContainer
    }()
    private lazy var distanceSettingLabel = {
        let distanceSettingLabel = UILabel()
        distanceSettingLabel.text = "최대 거리 설정"
        distanceSettingLabel.textColor = .black
        distanceSettingLabel.font = .systemFont(ofSize: 14, weight: .medium)
        distanceSettingLabel.translatesAutoresizingMaskIntoConstraints = false
        return distanceSettingLabel
    }()
    private lazy var distanceLabel = {
        let distanceSettingLabel = UILabel()
        distanceSettingLabel.text = "300m"
        distanceSettingLabel.textColor = .black
        distanceSettingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        distanceSettingLabel.translatesAutoresizingMaskIntoConstraints = false
        return distanceSettingLabel
    }()
    private lazy var distancePlusButton: UIButton = {
        let distancePlusButton = UIButton(type: .system)
        distancePlusButton.setImage(UIImage(systemName: "plus")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)).withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        distancePlusButton.backgroundColor = .white
        distancePlusButton.layer.cornerRadius = 11
        distancePlusButton.translatesAutoresizingMaskIntoConstraints = false
        return distancePlusButton
    }()
    private lazy var distanceMinusButton: UIButton = {
        let distanceMinusButton = UIButton(type: .system)
        distanceMinusButton.setImage(UIImage(systemName: "minus")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)).withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        distanceMinusButton.backgroundColor = .white
        distanceMinusButton.layer.cornerRadius = 11
        distanceMinusButton.translatesAutoresizingMaskIntoConstraints = false
        return distanceMinusButton
    }()
    private lazy var zoomInButton: UIButton = {
        let zoomInButton = UIButton(type: .system)
        zoomInButton.setImage(UIImage(systemName: "plus")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)).withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        zoomInButton.backgroundColor = .white
        zoomInButton.layer.borderColor = UIColor.systemGray.cgColor
        zoomInButton.translatesAutoresizingMaskIntoConstraints = false
        return zoomInButton
    }()
    private lazy var zoomOutButton: UIButton = {
        let zoomOutButton = UIButton(type: .system)
        zoomOutButton.setImage(UIImage(systemName: "minus")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)).withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        zoomOutButton.backgroundColor = .white
        zoomOutButton.layer.borderColor = UIColor.systemGray.cgColor
        zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
        return zoomOutButton
    }()
    private lazy var userLocationButton: UIButton = {
        let userLocationButton = UIButton(type: .system)
        userLocationButton.setImage(UIImage(systemName: "location.fill")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)), for: .normal)
        userLocationButton.backgroundColor = .white
        userLocationButton.layer.borderColor = UIColor.systemGray.cgColor
        userLocationButton.translatesAutoresizingMaskIntoConstraints = false
        return userLocationButton
    }()
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addBorder(to: zoomInButton, edges: [.top, .left, .right, .bottom], color: .systemGray, width: 1)
        addBorder(to: zoomOutButton, edges: [.bottom, .left, .right], color: .systemGray, width: 1)
        addBorder(to: userLocationButton, edges: [.top, .left, .right, .bottom], color: .systemGray, width: 1)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(placeContainer)
        placeContainer.addSubview(placeSettingLabel)
        placeContainer.addSubview(currentLocationButton)
        placeContainer.addSubview(separatorLine)
        placeContainer.addSubview(searchButton)
        view.addSubview(distanceContainer)
        distanceContainer.addSubview(distanceSettingLabel)
        distanceContainer.addSubview(distanceLabel)
        distanceContainer.addSubview(distancePlusButton)
        distanceContainer.addSubview(distanceMinusButton)
        view.addSubview(zoomInButton)
        view.addSubview(zoomOutButton)
        view.addSubview(userLocationButton)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            placeContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            placeContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            placeContainer.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            
            placeSettingLabel.topAnchor.constraint(equalTo: placeContainer.topAnchor, constant: 6),
            placeSettingLabel.bottomAnchor.constraint(equalTo: placeContainer.bottomAnchor, constant: -6),
            placeSettingLabel.leadingAnchor.constraint(equalTo: placeContainer.leadingAnchor, constant: 15),
            
            currentLocationButton.topAnchor.constraint(equalTo: placeSettingLabel.topAnchor),
            currentLocationButton.bottomAnchor.constraint(equalTo: placeSettingLabel.bottomAnchor),
            currentLocationButton.trailingAnchor.constraint(equalTo: separatorLine.leadingAnchor, constant: -8),
            
            separatorLine.topAnchor.constraint(equalTo: placeSettingLabel.topAnchor, constant: 4),
            separatorLine.bottomAnchor.constraint(equalTo: placeSettingLabel.bottomAnchor, constant: -4),
            separatorLine.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -8),
            separatorLine.widthAnchor.constraint(equalToConstant: 1),
            
            searchButton.topAnchor.constraint(equalTo: placeSettingLabel.topAnchor),
            searchButton.bottomAnchor.constraint(equalTo: placeSettingLabel.bottomAnchor),
            searchButton.trailingAnchor.constraint(equalTo: placeContainer.trailingAnchor, constant: -15),
            
            distanceContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            distanceContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            distanceContainer.topAnchor.constraint(equalTo: placeContainer.bottomAnchor, constant: 4),
            distanceContainer.heightAnchor.constraint(equalTo: placeContainer.heightAnchor),
            
            distanceSettingLabel.topAnchor.constraint(equalTo: distanceContainer.topAnchor, constant: 6),
            distanceSettingLabel.bottomAnchor.constraint(equalTo: distanceContainer.bottomAnchor, constant: -6),
            distanceSettingLabel.leadingAnchor.constraint(equalTo: distanceContainer.leadingAnchor, constant: 15),
            
            distanceMinusButton.centerYAnchor.constraint(equalTo: distanceContainer.centerYAnchor),
            distanceMinusButton.heightAnchor.constraint(equalToConstant: 22),
            distanceMinusButton.widthAnchor.constraint(equalToConstant: 22),
            distanceMinusButton.trailingAnchor.constraint(equalTo: distanceLabel.leadingAnchor, constant: -15),
            
            distanceLabel.topAnchor.constraint(equalTo: distanceSettingLabel.topAnchor),
            distanceLabel.bottomAnchor.constraint(equalTo: distanceSettingLabel.bottomAnchor),
            distanceLabel.trailingAnchor.constraint(equalTo: distancePlusButton.leadingAnchor, constant: -15),
            
            distancePlusButton.centerYAnchor.constraint(equalTo: distanceContainer.centerYAnchor),
            distancePlusButton.heightAnchor.constraint(equalToConstant: 22),
            distancePlusButton.widthAnchor.constraint(equalToConstant: 22),
            distancePlusButton.trailingAnchor.constraint(equalTo: distanceContainer.trailingAnchor, constant: -12),
            
        ])
    }
    
    // 겹치는 부분 중복 테두리 방지를 위한 테두리 추가 함수
    private func addBorder(to button: UIButton, edges: UIRectEdge, color: UIColor, width: CGFloat) {
        DispatchQueue.main.async {
            if edges.contains(.top) {
                let topBorder = CALayer()
                topBorder.backgroundColor = color.cgColor
                topBorder.frame = CGRect(x: 0, y: 0, width: button.frame.width, height: width)
                button.layer.addSublayer(topBorder)
            }
            if edges.contains(.bottom) {
                let bottomBorder = CALayer()
                bottomBorder.backgroundColor = color.cgColor
                bottomBorder.frame = CGRect(x: 0, y: button.frame.height - width, width: button.frame.width, height: width)
                button.layer.addSublayer(bottomBorder)
            }
            if edges.contains(.left) {
                let leftBorder = CALayer()
                leftBorder.backgroundColor = color.cgColor
                leftBorder.frame = CGRect(x: 0, y: 0, width: width, height: button.frame.height)
                button.layer.addSublayer(leftBorder)
            }
            if edges.contains(.right) {
                let rightBorder = CALayer()
                rightBorder.backgroundColor = color.cgColor
                rightBorder.frame = CGRect(x: button.frame.width - width, y: 0, width: width, height: button.frame.height)
                button.layer.addSublayer(rightBorder)
            }
        }
    }
}

//MARK: MapDelegate 함수
extension RestaurantMapViewController: MKMapViewDelegate {
    // Mappin
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let identifier = "CustomAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
            annotationView?.contentMode = .scaleAspectFit
        } else {
            annotationView?.annotation = annotation
        }
        
        if let image = UIImage(named: "mappinImage") {
            let size = CGSize(width: 50, height: 50)
            UIGraphicsBeginImageContext(size)
            image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            annotationView?.image = resizedImage
        }
        
        return annotationView
        }
}
