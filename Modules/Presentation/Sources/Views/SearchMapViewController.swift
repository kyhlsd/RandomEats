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
    
    private var searchPlaceViewModel: SearchPlaceViewModel
    weak var delegate: SearchPageNavigationDelegate?
    
    init(searchPlaceViewModel: SearchPlaceViewModel) {
        self.searchPlaceViewModel = searchPlaceViewModel
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
    private lazy var placeContainer: UIView = {
        let placeContainer = UIView()
        placeContainer.layer.cornerRadius = 10
        placeContainer.layer.masksToBounds = true
        placeContainer.layer.borderColor = UIColor.systemGray.cgColor
        placeContainer.layer.borderWidth = 1
        placeContainer.backgroundColor = .white
        placeContainer.translatesAutoresizingMaskIntoConstraints = false
        return placeContainer
    }()
    private lazy var placeNameLabel = {
        let placeNameLabel = UILabel()
        placeNameLabel.text = ""
        placeNameLabel.textColor = .black
        placeNameLabel.font = .systemFont(ofSize: 20, weight: .medium)
        placeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeNameLabel
    }()
    private lazy var placeAddressLabel = {
        let placeAddressLabel = UILabel()
        placeAddressLabel.text = ""
        placeAddressLabel.textColor = .systemGray
        placeAddressLabel.font = .systemFont(ofSize: 15, weight: .medium)
        placeAddressLabel.numberOfLines = 2
        placeAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeAddressLabel
    }()
    private lazy var setLocationButton = {
        var config = UIButton.Configuration.plain()
        
        var attributeContainer = AttributeContainer()
        attributeContainer.font = UIFont.boldSystemFont(ofSize: 15)
        config.attributedTitle = AttributedString("이곳으로 위치 설정하기", attributes: attributeContainer)
        config.baseForegroundColor = .black
        config.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
        
        let setLocationButton = UIButton()
        setLocationButton.configuration = config
        setLocationButton.backgroundColor = UIColor(named: "SecondaryColor")
        setLocationButton.layer.cornerRadius = 10
        setLocationButton.translatesAutoresizingMaskIntoConstraints = false
        return setLocationButton
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
        
        setButtonActions()
        
        updateMapView()
        
    }
    
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(zoomInButton)
        view.addSubview(zoomOutButton)
        view.addSubview(userLocationButton)
        view.addSubview(placeContainer)
        placeContainer.addSubview(placeNameLabel)
        placeContainer.addSubview(placeAddressLabel)
        placeContainer.addSubview(setLocationButton)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            userLocationButton.bottomAnchor.constraint(equalTo: placeContainer.topAnchor, constant: -20),
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
            
            placeContainer.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -14),
            placeContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            placeContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            
            placeNameLabel.leadingAnchor.constraint(equalTo: placeContainer.leadingAnchor, constant: 10),
            placeNameLabel.trailingAnchor.constraint(equalTo: placeContainer.trailingAnchor, constant: -10),
            placeNameLabel.topAnchor.constraint(equalTo: placeContainer.topAnchor, constant: 10),
            
            placeAddressLabel.leadingAnchor.constraint(equalTo: placeContainer.leadingAnchor, constant: 10),
            placeAddressLabel.trailingAnchor.constraint(equalTo: placeContainer.trailingAnchor, constant: -10),
            placeAddressLabel.topAnchor.constraint(equalTo: placeNameLabel.bottomAnchor, constant: 6),
            
            setLocationButton.leadingAnchor.constraint(equalTo: placeContainer.leadingAnchor, constant: 10),
            setLocationButton.trailingAnchor.constraint(equalTo: placeContainer.trailingAnchor, constant: -10),
            setLocationButton.topAnchor.constraint(equalTo: placeAddressLabel.bottomAnchor, constant: 20),
            setLocationButton.bottomAnchor.constraint(equalTo: placeContainer.bottomAnchor, constant: -14),
        ])
    }
    
    func updateMapView() {
        if let placeLocation = searchPlaceViewModel.placeLocation {
            centerMapOnLocation(location: placeLocation)
            addAnnotation()
            DispatchQueue.main.async {
                self.placeNameLabel.text = self.searchPlaceViewModel.selectedPrediction?.mainText
                self.placeAddressLabel.text = self.searchPlaceViewModel.selectedPrediction?.description
            }
        }
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
        if let placeLocation = searchPlaceViewModel.placeLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: placeLocation.getLatitude(), longitude: placeLocation.getLongitude())
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func adjustZoom(by factor: Double) {
        var region = mapView.region
        region.span.latitudeDelta *= factor
        region.span.longitudeDelta *= factor
        mapView.setRegion(region, animated: true)
    }
    
    private func setButtonActions() {
        zoomInButton.addAction(UIAction { [weak self] _ in
            self?.adjustZoom(by: 0.5)
        }, for: .touchUpInside)
        
        zoomOutButton.addAction(UIAction { [weak self] _ in
            self?.adjustZoom(by: 2.0)
        }, for: .touchUpInside)
        
        setLocationButton.addAction(UIAction { [weak self] _ in
            if let placeLocation = self?.searchPlaceViewModel.placeLocation {
                self?.delegate?.dismissModal(with: placeLocation)
            }
        }, for: .touchUpInside)
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
