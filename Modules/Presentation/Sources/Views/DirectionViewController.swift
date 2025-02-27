//
//  DirectionViewController.swift
//  Data
//
//  Created by 김영훈 on 1/8/25.
//

import UIKit
import MapKit
import Domain
import Combine

class DirectionViewController: UIViewController {
    private let directionViewModel: DirectionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(directionViewModel: DirectionViewModel) {
        self.directionViewModel = directionViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var closeButton = {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        return closeButton
    }()
    private lazy var navigationBar = {
        let closeButtonItem = UIBarButtonItem(customView: closeButton)
        let navigationItem = UINavigationItem(title: "길찾기")
        navigationItem.rightBarButtonItem = closeButtonItem
        let navigationBar = UINavigationBar()
        navigationBar.setItems([navigationItem], animated: true)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.backgroundColor = UIColor(named: "PrimaryColor")
        navigationBar.shadowImage = UIImage()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
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
        
        setButtonActions()
        
        bindViewModel()
        
        fetchWalkingDirections(from: directionViewModel.originLocation, to: directionViewModel.destinationLocation)
        
        addAnnotation()
    }

    private func setupUI() {
        view.addSubview(navigationBar)
        view.addSubview(mapView)
        view.addSubview(zoomInButton)
        view.addSubview(zoomOutButton)
        view.addSubview(userLocationButton)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            mapView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
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
    
    private func adjustZoom(by factor: Double) {
        var region = mapView.region
        region.span.latitudeDelta *= factor
        region.span.longitudeDelta *= factor
        mapView.setRegion(region, animated: true)
    }
    
    private func setButtonActions() {
        closeButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        zoomInButton.addAction(UIAction { [weak self] _ in
            self?.adjustZoom(by: 0.5)
        }, for: .touchUpInside)
        
        zoomOutButton.addAction(UIAction { [weak self] _ in
            self?.adjustZoom(by: 2.0)
        }, for: .touchUpInside)
        
        userLocationButton.addAction(UIAction { [weak self] _ in
            DispatchQueue.main.async {
                self?.mapView.showsUserLocation.toggle()
                if self?.mapView.showsUserLocation == true {
                    self?.directionViewModel.fetchCurrentLocation()
                }
            }
        }, for: .touchUpInside)
    }
    
    private func bindViewModel() {
        // 에러 메시지 바인딩
        directionViewModel.$errorMessage
            .sink { errorMessage in
                if let errorMessage = errorMessage {
                    if errorMessage == LocationServiceError.permissionDenied.errorDescription {
                        self.showPermissionDeniedAlert()
                    } else if errorMessage == LocationServiceError.permissionRestricted.errorDescription {
                        self.showPermissionRestrictedAlert()
                    } else if errorMessage == LocationServiceError.unknownError.errorDescription {
                        self.showLocationUnknownErrorAlert()
                    }
                    else {
                        self.showErrorAlert(errorMessage: errorMessage)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchWalkingDirections(from origin: Location, to destination: Location) {
        let originCoordinate = CLLocationCoordinate2D(latitude: origin.getLatitude(), longitude: origin.getLongitude())
        let destinationCoordinate = CLLocationCoordinate2D(latitude: destination.getLatitude(), longitude: destination.getLongitude())
        
        let originPlacemark = MKPlacemark(coordinate: originCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let originItem = MKMapItem(placemark: originPlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = originItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { [weak self] response, error in
            if let error = error {
                print("Error calculating directions: \(error.localizedDescription)")
                return
            }
            
            guard let response = response, let route = response.routes.first else {
                print("No route found")
                return
            }
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
            centerMapOnLocation(location: directionViewModel.getAverageLocation(), regionRadius: CLLocationDistance(Int(Double(directionViewModel.getDistanceBetween()) * 1.3)), animated: true)
        }
    }
    
    private func centerMapOnLocation(location: Location, regionRadius: CLLocationDistance = 500, animated: Bool = false) {
        let coordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.getLatitude(), longitude: location.getLongitude()),
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        DispatchQueue.main.async {
            self.mapView.setRegion(coordinateRegion, animated: animated)
        }
    }
    
    private func addAnnotation() {
        let originAnnotation = DirectionPlaceAnnotation(type: .origin)
        originAnnotation.coordinate = CLLocationCoordinate2D(latitude: directionViewModel.originLocation.getLatitude(), longitude: directionViewModel.originLocation.getLongitude())
        
        let destinationAnnotation = DirectionPlaceAnnotation(type: .destination)
        destinationAnnotation.coordinate = CLLocationCoordinate2D(latitude: directionViewModel.destinationLocation.getLatitude(), longitude: directionViewModel.destinationLocation.getLongitude())
        
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotation(originAnnotation)
            self.mapView.addAnnotation(destinationAnnotation)
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
    //MARK: Alert 함수
    private func showPermissionDeniedAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "위치 서비스 권한 필요",
                message: self.directionViewModel.errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default, handler: { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            
            self.present(alert, animated: true)
        }
    }
    
    private func showPermissionRestrictedAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(
                title: "위치 서비스 권한 필요",
                message: self.directionViewModel.errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            
            self.present(alert, animated: true)
        }
    }
    
    private func showLocationUnknownErrorAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "위치 정보 가져오기 실패",
                message: self.directionViewModel.errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "닫기", style: .default))
            
            self.present(alert, animated: true)
        }
    }
    
    private func showErrorAlert(errorMessage: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "Error",
                message: errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "닫기", style: .default))
            
            self.present(alert, animated: true)
        }
    }
}

//MARK: MapDelegate 함수
extension DirectionViewController: MKMapViewDelegate {
    // Mappin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let directionPlaceAnnotation = annotation as? DirectionPlaceAnnotation else {
            return nil
        }
        
        let identifier = "DirectionPlaceAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
            annotationView?.contentMode = .scaleAspectFit
        } else {
            annotationView?.annotation = annotation
        }
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        
        switch directionPlaceAnnotation.type {
        case .origin:
            if let image = UIImage(named: "mappinFilledBlue") {
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: 52, height: 52)
                imageView.contentMode = .scaleAspectFit
                customView.addSubview(imageView)
            }
            
            let label = UILabel(frame: CGRect(x: 0, y: 10, width: 52, height: 20))
            label.text = "출발"
            label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            label.textAlignment = .center
            label.textColor = .white
            customView.addSubview(label)
        case .destination:
            if let image = UIImage(named: "mappinFilledGreen") {
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: 52, height: 52)
                imageView.contentMode = .scaleAspectFit
                customView.addSubview(imageView)
            }
            
            let label = UILabel(frame: CGRect(x: 0, y: 10, width: 52, height: 20))
            label.text = "도착"
            label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            label.textAlignment = .center
            label.textColor = .white
            customView.addSubview(label)
        }

        annotationView?.addSubview(customView)
        
        return annotationView
        }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer()
            }
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 4.0
            return renderer
        }
}

extension DirectionViewController: CenterMapBetweenLocationsDelegate {
    func centerMapBetweenLocations() {
        if mapView.showsUserLocation {
            // 현재 위치, 출발 위치, 도착 위치 중간으로 지도 세팅
            let averageLocation = directionViewModel.getAverageWithCurrentLocation()
            let distance = directionViewModel.getDistanceWithCurrentLocation()
            
            centerMapOnLocation(location: averageLocation, regionRadius: CLLocationDistance(Int(Double(distance) * 1.2)), animated: true)
        }
    }
}
