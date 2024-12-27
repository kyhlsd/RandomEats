//
//  SearchMapViewController.swift
//  Data
//
//  Created by 김영훈 on 12/23/24.
//

import UIKit
import MapKit
import Domain

class SearchMapViewController: UIViewController {
    var placeLocation = Location(latitude: 37.574475, longitude: 126.988776)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addBorder(to: zoomInButton, edges: [.top, .left, .right, .bottom], color: .systemGray, width: 1)
        addBorder(to: zoomOutButton, edges: [.bottom, .left, .right], color: .systemGray, width: 1)
        addBorder(to: userLocationButton, edges: [.top, .left, .right, .bottom], color: .systemGray, width: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        
        setupUI()
        
        centerMapOnLocation(location: placeLocation)
        
        addAnnotation()
        
    }
    
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(zoomInButton)
        view.addSubview(zoomOutButton)
        view.addSubview(userLocationButton)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            userLocationButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            userLocationButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            userLocationButton.widthAnchor.constraint(equalToConstant: 28),
            userLocationButton.heightAnchor.constraint(equalToConstant: 28),
            
            zoomOutButton.bottomAnchor.constraint(equalTo: userLocationButton.topAnchor, constant: -10),
            zoomOutButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            zoomOutButton.widthAnchor.constraint(equalToConstant: 28),
            zoomOutButton.heightAnchor.constraint(equalToConstant: 28),
            
            zoomInButton.bottomAnchor.constraint(equalTo: zoomOutButton.topAnchor),
            zoomInButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            zoomInButton.widthAnchor.constraint(equalToConstant: 28),
            zoomInButton.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    func updateMapView() {
        centerMapOnLocation(location: placeLocation)
        addAnnotation()
    }
    
    private func centerMapOnLocation(location: Location, regionRadius: CLLocationDistance = 500) {
        let coordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.getLatitude(), longitude: location.getLongitude()),
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        DispatchQueue.main.async {
            self.mapView.setRegion(coordinateRegion, animated: false)
        }
    }
    
    private func addAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: placeLocation.getLatitude(), longitude: placeLocation.getLongitude())
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotation(annotation)
        }
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

extension SearchMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
