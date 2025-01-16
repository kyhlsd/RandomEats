//
//  RestaurantMapViewController.swift
//  Presentation
//
//  Created by 김영훈 on 12/5/24.
//

import UIKit
import Kingfisher
import MapKit
import Combine
import Domain
import Data

public class RestaurantMapViewController: UIViewController {
    private let restaurantMapViewModel: RestaurantMapViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(restaurantMapViewModel: RestaurantMapViewModel) {
        self.restaurantMapViewModel = restaurantMapViewModel
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
    private lazy var placeSettingContainer = {
        let placeSettingContainer = UIView()
        placeSettingContainer.layer.cornerRadius = 10
        placeSettingContainer.layer.masksToBounds = true
        placeSettingContainer.backgroundColor = UIColor(named: "SecondaryColor")
        placeSettingContainer.translatesAutoresizingMaskIntoConstraints = false
        return placeSettingContainer
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
    private lazy var userLocationButtonBottomConstraint: NSLayoutConstraint = {
        let safeArea = view.safeAreaLayoutGuide
        let userLocationButtonBottomConstraint = userLocationButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20)
        return userLocationButtonBottomConstraint
    }()
    private lazy var placeContainer: UIView = {
        let placeContainer = UIView()
        placeContainer.layer.cornerRadius = 10
        placeContainer.layer.masksToBounds = true
        placeContainer.layer.borderColor = UIColor.systemGray.cgColor
        placeContainer.layer.borderWidth = 1
        placeContainer.backgroundColor = .white
        placeContainer.isHidden = true
        placeContainer.translatesAutoresizingMaskIntoConstraints = false
        return placeContainer
    }()
    private lazy var placeImageView = {
        let placeImageView = UIImageView()
        placeImageView.image = UIImage(named: "SampleRestaurantImage")
        placeImageView.layer.cornerRadius = 10
        placeImageView.clipsToBounds = true
        placeImageView.translatesAutoresizingMaskIntoConstraints = false
        return placeImageView
    }()
    private lazy var placeNameLabel = {
        let placeNameLabel = UILabel()
        placeNameLabel.text = "스톤504"
        placeNameLabel.textColor = .black
        placeNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        placeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeNameLabel
    }()
    private lazy var noImageLabel = {
        let noImageLabel = UILabel()
        noImageLabel.text = "No Image"
        noImageLabel.textAlignment = .center
        noImageLabel.textColor = .gray
        noImageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        noImageLabel.translatesAutoresizingMaskIntoConstraints = false
        noImageLabel.isHidden = true
        return noImageLabel
    }()
    private lazy var ratingLabel = {
        let ratingLabel = UILabel()
        ratingLabel.text = "평점 : 4.1 (10)"
        ratingLabel.textColor = .black
        ratingLabel.font = .systemFont(ofSize: 13, weight: .medium)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        return ratingLabel
    }()
    private lazy var ratingStack = {
        let firstStar = UIImageView(image: UIImage(systemName: "star.fill"))
        let secondStar = UIImageView(image: UIImage(systemName: "star.fill"))
        let thirdStar = UIImageView(image: UIImage(systemName: "star.leadinghalf.filled"))
        let fourthStar = UIImageView(image: UIImage(systemName: "star"))
        let fifthStar = UIImageView(image: UIImage(systemName: "star"))
        
        [firstStar, secondStar, thirdStar, fourthStar, fifthStar].forEach { star in
            star.tintColor = UIColor(named: "ContrastColor")
                star.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    star.widthAnchor.constraint(equalToConstant: 14),
                    star.heightAnchor.constraint(equalToConstant: 14)
                ])
            }
        
        let ratingStack = UIStackView(arrangedSubviews: [firstStar, secondStar, thirdStar, fourthStar, fifthStar])
        ratingStack.axis = .horizontal
        ratingStack.distribution = .equalSpacing
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
       return ratingStack
    }()
    private lazy var restaurantDistanceLabel = {
        let restaurantDistanceLabel = UILabel()
        restaurantDistanceLabel.text = "거리 : 170 m"
        restaurantDistanceLabel.textColor = .black
        restaurantDistanceLabel.font = .systemFont(ofSize: 13, weight: .medium)
        restaurantDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        return restaurantDistanceLabel
    }()
    private lazy var restaurantInfoButton = {
        let restaurantInfoButton = UIButton()
        restaurantInfoButton.setTitle("식당 정보 보기", for: .normal)
        restaurantInfoButton.setTitleColor(.systemBlue, for: .normal)
        restaurantInfoButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        restaurantInfoButton.translatesAutoresizingMaskIntoConstraints = false
        return restaurantInfoButton
    }()
    private lazy var directionsButton = {
        var config = UIButton.Configuration.plain()
        
        var attributeContainer = AttributeContainer()
        attributeContainer.font = UIFont.boldSystemFont(ofSize: 15)
        config.attributedTitle = AttributedString("길찾기", attributes: attributeContainer)
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "arrow.triangle.turn.up.right.diamond.fill")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
        
        let directionsButton = UIButton()
        directionsButton.configuration = config
        directionsButton.backgroundColor = .black
        directionsButton.layer.cornerRadius = 10
        directionsButton.translatesAutoresizingMaskIntoConstraints = false
        return directionsButton
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
        
        bindViewModel()
        
        setupUI()
        
        setButtonActions()
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateMapView()
    }
    
    private func bindViewModel() {
        // 설정된 위치 바인딩
        restaurantMapViewModel.$setLocation
            .sink { setLocation in
                if let setLocation = setLocation {
                    self.centerMapOnLocation(location: setLocation, animated: true)
                }
            }
            .store(in: &cancellables)
        // 에러 메시지 바인딩
        restaurantMapViewModel.$errorMessage
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
                        print("Error: \(errorMessage)")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(placeSettingContainer)
        placeSettingContainer.addSubview(placeSettingLabel)
        placeSettingContainer.addSubview(currentLocationButton)
        placeSettingContainer.addSubview(separatorLine)
        placeSettingContainer.addSubview(searchButton)
        view.addSubview(distanceContainer)
        distanceContainer.addSubview(distanceSettingLabel)
        distanceContainer.addSubview(distanceLabel)
        distanceContainer.addSubview(distancePlusButton)
        distanceContainer.addSubview(distanceMinusButton)
        view.addSubview(zoomInButton)
        view.addSubview(zoomOutButton)
        view.addSubview(userLocationButton)
        view.addSubview(placeContainer)
        placeContainer.addSubview(placeImageView)
        placeContainer.addSubview(noImageLabel)
        placeContainer.addSubview(placeNameLabel)
        placeContainer.addSubview(ratingLabel)
        placeContainer.addSubview(ratingStack)
        placeContainer.addSubview(restaurantDistanceLabel)
        placeContainer.addSubview(restaurantInfoButton)
        placeContainer.addSubview(directionsButton)
        
        let safeArea = view.safeAreaLayoutGuide
        userLocationButtonBottomConstraint = userLocationButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            placeSettingContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            placeSettingContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            placeSettingContainer.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            
            placeSettingLabel.topAnchor.constraint(equalTo: placeSettingContainer.topAnchor, constant: 6),
            placeSettingLabel.bottomAnchor.constraint(equalTo: placeSettingContainer.bottomAnchor, constant: -6),
            placeSettingLabel.leadingAnchor.constraint(equalTo: placeSettingContainer.leadingAnchor, constant: 15),
            
            currentLocationButton.topAnchor.constraint(equalTo: placeSettingLabel.topAnchor),
            currentLocationButton.bottomAnchor.constraint(equalTo: placeSettingLabel.bottomAnchor),
            currentLocationButton.trailingAnchor.constraint(equalTo: separatorLine.leadingAnchor, constant: -8),
            
            separatorLine.topAnchor.constraint(equalTo: placeSettingLabel.topAnchor, constant: 4),
            separatorLine.bottomAnchor.constraint(equalTo: placeSettingLabel.bottomAnchor, constant: -4),
            separatorLine.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -8),
            separatorLine.widthAnchor.constraint(equalToConstant: 1),
            
            searchButton.topAnchor.constraint(equalTo: placeSettingLabel.topAnchor),
            searchButton.bottomAnchor.constraint(equalTo: placeSettingLabel.bottomAnchor),
            searchButton.trailingAnchor.constraint(equalTo: placeSettingContainer.trailingAnchor, constant: -15),
            
            distanceContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            distanceContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            distanceContainer.topAnchor.constraint(equalTo: placeSettingContainer.bottomAnchor, constant: 4),
            distanceContainer.heightAnchor.constraint(equalTo: placeSettingContainer.heightAnchor),
            
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
            
            userLocationButtonBottomConstraint,
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
            
            placeImageView.leadingAnchor.constraint(equalTo: placeContainer.leadingAnchor, constant: 12),
            placeImageView.topAnchor.constraint(equalTo: placeContainer.topAnchor, constant: 12),
            placeImageView.bottomAnchor.constraint(equalTo: placeContainer.bottomAnchor, constant: -12),
            placeImageView.heightAnchor.constraint(equalToConstant: 80),
            placeImageView.widthAnchor.constraint(equalToConstant: 80),
            
            placeNameLabel.topAnchor.constraint(equalTo: placeImageView.topAnchor),
            placeNameLabel.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 12),
            placeNameLabel.trailingAnchor.constraint(equalTo: placeContainer.trailingAnchor, constant: -12),
            
            noImageLabel.centerXAnchor.constraint(equalTo: placeImageView.centerXAnchor),
            noImageLabel.bottomAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: -6),
            
            ratingLabel.leadingAnchor.constraint(equalTo: placeNameLabel.leadingAnchor),
            ratingLabel.topAnchor.constraint(equalTo: placeNameLabel.bottomAnchor, constant: 6),
            
            ratingStack.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 5),
            ratingStack.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            
            restaurantDistanceLabel.leadingAnchor.constraint(equalTo: placeNameLabel.leadingAnchor),
            restaurantDistanceLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 4),
            
            restaurantInfoButton.leadingAnchor.constraint(equalTo: placeNameLabel.leadingAnchor),
            restaurantInfoButton.topAnchor.constraint(equalTo: restaurantDistanceLabel.bottomAnchor, constant: -3),
            
            directionsButton.trailingAnchor.constraint(equalTo: placeContainer.trailingAnchor, constant: -12),
            directionsButton.widthAnchor.constraint(equalToConstant: 90),
            directionsButton.centerYAnchor.constraint(equalTo: placeContainer.centerYAnchor),
        ])
    }
    
    private func setButtonActions() {
        currentLocationButton.addAction(UIAction { [weak self] _ in
            self?.restaurantMapViewModel.fetchCurrentLocationAndAddressForSet()
        }, for: .touchUpInside)
        
        searchButton.addAction(UIAction { [weak self] _ in
            let searchPageViewController = SearchPageViewController()
            searchPageViewController.locationViewModelDelegate = self?.restaurantMapViewModel.locationViewModel
            searchPageViewController.setAddressWithSearchedResultDelegate = self?.restaurantMapViewModel
            self?.present(searchPageViewController, animated: true, completion: nil)
        }, for: .touchUpInside)
        
        restaurantInfoButton.addAction(UIAction { [weak self] _ in
            guard let selectedRestaurantIndex = self?.restaurantMapViewModel.selectedRestaurantIndex, let placeDetail = self?.restaurantMapViewModel.bestRestaurants[selectedRestaurantIndex] else { return }
            let webViewController = WebViewController(urlString: placeDetail.url)
            self?.present(webViewController, animated: true, completion: nil)
            
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
                    self?.restaurantMapViewModel.fetchCurrentLocation()
                }
            }
        }, for: .touchUpInside)
        
        directionsButton.addAction(UIAction { [weak self] _ in
            guard let selectedRestaurantIndex = self?.restaurantMapViewModel.selectedRestaurantIndex, let originLocation = self?.restaurantMapViewModel.setLocation, let destinationLocation = self?.restaurantMapViewModel.bestRestaurants[selectedRestaurantIndex].geometry.location else { return }
            
            let locationService = LocationServiceImplementation()
            let locationRepository = LocationRepositoryImplementation(locationService: locationService)
            let locationUseCase = LocationUseCase(locationRepository: locationRepository)
            let directionViewModel = DirectionViewModel(originLocation: originLocation, destinationLocation: destinationLocation, locationUseCase: locationUseCase)
            let directionViewController = DirectionViewController(directionViewModel: directionViewModel)
            directionViewModel.delegate = directionViewController
            self?.present(directionViewController, animated: true)
        }, for: .touchUpInside)
    }
    
    private func adjustZoom(by factor: Double) {
        var region = mapView.region
        region.span.latitudeDelta *= factor
        region.span.longitudeDelta *= factor
        DispatchQueue.main.async {
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    private func updateMapView() {
        if let location = restaurantMapViewModel.setLocation {
            centerMapOnLocation(location: location)
            addAnnotation()
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
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        for bestRestaurant in restaurantMapViewModel.bestRestaurants {
            let annotation = BestRestaurantAnnotation(type: .nonSelected)
            annotation.coordinate = CLLocationCoordinate2D(latitude: bestRestaurant.geometry.location.getLatitude(), longitude: bestRestaurant.geometry.location.getLongitude())
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    private func updateAnnotation() {
        for annotation in mapView.annotations.compactMap({ $0 as? BestRestaurantAnnotation }) {
            let newImage: UIImage?
            let size = CGSize(width: 60, height: 60)
            UIGraphicsBeginImageContext(size)
            switch annotation.type {
            case .selected:
                newImage = UIImage(named: "selectedMappinImage")
                newImage?.draw(in: CGRect(x: 0, y: 0, width: 60, height: 60))
            case .nonSelected:
                newImage = UIImage(named: "mappinImage")
                newImage?.draw(in: CGRect(x: 0, y: 0, width: 44, height: 44))
            }
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            if let annotationView = mapView.view(for: annotation) {
                DispatchQueue.main.async {
                    annotationView.image = resizedImage
                }
            }
        }
    }
    private func updatePlaceContainer() {
        guard let selectedRestaurantIndex = restaurantMapViewModel.selectedRestaurantIndex else { return }
        let selectedPlaceDetail = restaurantMapViewModel.bestRestaurants[selectedRestaurantIndex]
        DispatchQueue.main.async {
            self.placeNameLabel.text = selectedPlaceDetail.name
            self.ratingLabel.text = "평점 : \(selectedPlaceDetail.rating ?? 0.0) (\(selectedPlaceDetail.user_ratings_total ?? 0))"
            self.updateRatingStars(rating: selectedPlaceDetail.rating ?? 0.0)
        }
        
        let photoImage = UIImage(systemName: "photo")?
            .withTintColor(.gray, renderingMode: .alwaysOriginal)
        let resizedImage = resizeImage(image: photoImage, to: CGSize(width: 80, height: 80))
        let paddedImage = addPaddingToImage(image: resizedImage, paddingSize: 80, paddingColor: .white)
        
        // TODO: photo url 가져오기, 거리 가져오기
//        if let photoURL =  {
//            // 이미지 정보가 있는 식당일 경우
//            DispatchQueue.main.async {
//                self.placeImageView.kf.setImage(with: photoURL, placeholder: paddedImage, options: [
//                    .cacheOriginalImage,
//                ])
//                self.noImageLabel.isHidden = true
//            }
//        } else {
//            // 이미지 정보가 없는 식당일 경우
//            DispatchQueue.main.async {
//                self.placeImageView.image = paddedImage
//                self.noImageLabel.isHidden = false
//            }
//        }
    }
    //MARK: Alert 함수
    private func showPermissionDeniedAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "위치 서비스 권한 필요",
                message: self.restaurantMapViewModel.errorMessage,
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
                message: self.restaurantMapViewModel.errorMessage,
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
                message: self.restaurantMapViewModel.errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "닫기", style: .default))
            
            self.present(alert, animated: true)
        }
    }
    
    //MARK: UI 보조 함수
    // 식당 평점 별 UI 업데이트
    private func updateRatingStars(rating: Double) {
        let starStates: [String] = {
            switch rating {
            case ..<0.25: return ["star", "star", "star", "star", "star"]
            case 0.25..<0.75: return ["star.leadinghalf.filled", "star", "star", "star", "star"]
            case 0.75..<1.25: return ["star.fill", "star", "star", "star", "star"]
            case 1.25..<1.75: return ["star.fill", "star.leadinghalf.filled", "star", "star", "star"]
            case 1.75..<2.25: return ["star.fill", "star.fill", "star", "star", "star"]
            case 2.25..<2.75: return ["star.fill", "star.fill", "star.leadinghalf.filled", "star", "star"]
            case 2.75..<3.25: return ["star.fill", "star.fill", "star.fill", "star", "star"]
            case 3.25..<3.75: return ["star.fill", "star.fill", "star.fill", "star.leadinghalf.filled", "star"]
            case 3.75..<4.25: return ["star.fill", "star.fill", "star.fill", "star.fill", "star"]
            case 4.25..<4.75: return ["star.fill", "star.fill", "star.fill", "star.fill", "star.leadinghalf.filled"]
            default: return ["star.fill", "star.fill", "star.fill", "star.fill", "star.fill"]
            }
        }()
        
        for (index, state) in starStates.enumerated() {
            if let star = ratingStack.arrangedSubviews[index] as? UIImageView {
                star.image = UIImage(systemName: state)
            }
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
    // 이미지 크기 조정 함수
    private func resizeImage(image: UIImage?, to size: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }

    // 이미지에 여백 추가 함수
    private func addPaddingToImage(image: UIImage?, paddingSize: CGFloat, paddingColor: UIColor) -> UIImage? {
        guard let image = image else { return nil }
        
        let newSize = CGSize(width: image.size.width + paddingSize * 2, height: image.size.height + paddingSize * 2)
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        
        // 배경색을 지정
        paddingColor.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: newSize)).fill()
        
        // 이미지를 지정된 위치에 그리기
        let imageRect = CGRect(x: paddingSize, y: paddingSize, width: image.size.width, height: image.size.height)
        image.draw(in: imageRect)
        
        let paddedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return paddedImage
    }
}

//MARK: MapDelegate 함수
extension RestaurantMapViewController: MKMapViewDelegate {
    // Mappin
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let directionPlaceAnnotation = annotation as? BestRestaurantAnnotation else {
            return nil
        }
        
        let identifier = "BestRestaurantAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
            annotationView?.contentMode = .scaleAspectFit
        } else {
            annotationView?.annotation = annotation
        }
        
        var mappinImage: UIImage?
        let size = CGSize(width: 60, height: 60)
        UIGraphicsBeginImageContext(size)
        switch directionPlaceAnnotation.type {
        case .selected:
            mappinImage = UIImage(named: "selectedMappinImage")
            mappinImage?.draw(in: CGRect(x: 0, y: 0, width: 60, height: 60))
        case .nonSelected:
            mappinImage = UIImage(named: "mappinImage")
            mappinImage?.draw(in: CGRect(x: 0, y: 0, width: 44, height: 44))
        }
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        annotationView?.image = resizedImage
        
        return annotationView
    }
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotation) {
        guard let selectedAnnotation = view as? BestRestaurantAnnotation else { return }
        
        if let selectedIndex = restaurantMapViewModel.bestRestaurants.firstIndex(where: {
            $0.geometry.location.getLatitude() == selectedAnnotation.coordinate.latitude &&
            $0.geometry.location.getLongitude() == selectedAnnotation.coordinate.longitude
        }) {
            for annotation in mapView.annotations.compactMap({ $0 as? BestRestaurantAnnotation }) {
                annotation.type = .nonSelected
            }
            // 이미 어노테이션이 선택되어있을 경우 선택 해제
            if restaurantMapViewModel.selectedRestaurantIndex == selectedIndex {
                restaurantMapViewModel.selectedRestaurantIndex = nil
                let safeArea = self.view.safeAreaLayoutGuide
                DispatchQueue.main.async {
                    self.placeContainer.isHidden = true
                    self.userLocationButtonBottomConstraint.isActive = false
                    self.userLocationButtonBottomConstraint = self.userLocationButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20)
                    self.userLocationButtonBottomConstraint.isActive = true
                    self.view.layoutIfNeeded()
                }
            } else {
                // 새로운 어노테이션 선택 시
                restaurantMapViewModel.selectedRestaurantIndex = selectedIndex
                selectedAnnotation.type = .selected
                DispatchQueue.main.async {
                    self.placeContainer.isHidden = false
                    self.userLocationButtonBottomConstraint.isActive = false
                    self.userLocationButtonBottomConstraint = self.userLocationButton.bottomAnchor.constraint(equalTo: self.placeContainer.topAnchor, constant: -20)
                    self.userLocationButtonBottomConstraint.isActive = true
                    self.view.layoutIfNeeded()
                }
                updatePlaceContainer()
            }
        }
        
        updateAnnotation()
        mapView.deselectAnnotation(selectedAnnotation, animated: false)
    }
}

extension RestaurantMapViewController: CenterMapBetweenLocationsDelegate {
    public func centerMapBetweenLocations() {
        if mapView.showsUserLocation {
            // 현재 위치와 설정된 위치의 중간으로 지도 세팅
            if let averageLocation = restaurantMapViewModel.getAverageLocation(), let distance = restaurantMapViewModel.getDistanceBetween() {
                centerMapOnLocation(location: averageLocation, regionRadius: CLLocationDistance(Int(Double(distance) * 1.2)), animated: true)
            }
        }
    }
}
