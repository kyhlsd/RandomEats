//
//  RandomRecommendViewController.swift
//  Data
//
//  Created by 김영훈 on 11/28/24.
//

import UIKit
import Combine
import CombineCocoa
import Kingfisher
import Data
import Domain

public class RandomRecommendViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    private var randomRecommendViewModel: RandomRecommendViewModel
    
    public init(randomRecommendViewModel: RandomRecommendViewModel) {
        self.randomRecommendViewModel = randomRecommendViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleImageView = {
        let titleImageView = UIImageView()
        titleImageView.image = UIImage(systemName: "fork.knife")
        titleImageView.tintColor = .black
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        return titleImageView
    }()
    private lazy var titleLabel = {
        let titleLabel = UILabel()
        titleLabel.text = "RandomEats"
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    private let separatorLine: UIView = {
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor(named: "ContrastColor")
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        return separatorLine
    }()
    private lazy var placeSettingLabel = {
        let placeSettingLabel = UILabel()
        placeSettingLabel.text = "위치 설정"
        placeSettingLabel.textColor = .black
        placeSettingLabel.font = .systemFont(ofSize: 13, weight: .medium)
        placeSettingLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeSettingLabel
    }()
    private lazy var currentLocationButton = {
        let currentLocationButton = UIButton()
        currentLocationButton.setTitle("현재 위치로", for: .normal)
        currentLocationButton.setTitleColor(.systemBlue, for: .normal)
        currentLocationButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        return currentLocationButton
    }()
    private lazy var placeContainer = {
        let placeContainer = UIView()
        placeContainer.layer.cornerRadius = 10
        placeContainer.layer.masksToBounds = true
        placeContainer.backgroundColor = UIColor(named: "SecondaryColor")
        placeContainer.translatesAutoresizingMaskIntoConstraints = false
        return placeContainer
    }()
    private lazy var placeLabel = {
        let placeLabel = UILabel()
        placeLabel.text = "숭실대학교"
        placeLabel.textColor = .black
        placeLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeLabel
    }()
    private lazy var searchButton = {
        let searchButton = UIButton()
        searchButton.setImage(UIImage(systemName: "location.magnifyingglass"), for: .normal)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        return searchButton
    }()
    private lazy var distanceSettingLabel = {
        let distanceSettingLabel = UILabel()
        distanceSettingLabel.text = "최대 거리 설정 (\(randomRecommendViewModel.maximumDistance)m)"
        distanceSettingLabel.textColor = .black
        distanceSettingLabel.font = .systemFont(ofSize: 13, weight: .medium)
        distanceSettingLabel.translatesAutoresizingMaskIntoConstraints = false
        return distanceSettingLabel
    }()
    private lazy var distanceContainer = {
        let distanceContainer = UIView()
        distanceContainer.layer.cornerRadius = 10
        distanceContainer.layer.masksToBounds = true
        distanceContainer.backgroundColor = UIColor(named: "SecondaryColor")
        distanceContainer.translatesAutoresizingMaskIntoConstraints = false
        return distanceContainer
    }()
    private lazy var distanceSlider = {
        let distanceSlider = UISlider()
        distanceSlider.minimumValue = 0
        distanceSlider.maximumValue = 1
        distanceSlider.value = 0.5
        distanceSlider.translatesAutoresizingMaskIntoConstraints = false
        return distanceSlider
    }()
    private lazy var distanceLabelStack = {
        let firstDistanceLabel = UILabel()
        firstDistanceLabel.text = "100m"
        firstDistanceLabel.textColor = .black
        firstDistanceLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        
        let secondDistanceLabel = UILabel()
        secondDistanceLabel.text = "300m"
        secondDistanceLabel.textColor = .black
        secondDistanceLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        
        let thirdDistanceLabel = UILabel()
        thirdDistanceLabel.text = "500m"
        thirdDistanceLabel.textColor = .black
        thirdDistanceLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        
        let distanceLabelStack = UIStackView(arrangedSubviews: [
            firstDistanceLabel, secondDistanceLabel, thirdDistanceLabel
        ])
        distanceLabelStack.axis = .horizontal
        distanceLabelStack.distribution = .equalSpacing
        distanceLabelStack.translatesAutoresizingMaskIntoConstraints = false
        return distanceLabelStack
    }()
    private lazy var recommendRestaurantLabel = {
        let recommendRestaurantLabel = UILabel()
        recommendRestaurantLabel.text = "추천 식당"
        recommendRestaurantLabel.textColor = .black
        recommendRestaurantLabel.font = .systemFont(ofSize: 13, weight: .medium)
        recommendRestaurantLabel.translatesAutoresizingMaskIntoConstraints = false
        return recommendRestaurantLabel
    }()
    private lazy var randomRecommendButton = {
        var config = UIButton.Configuration.plain()
        
        var attributeContainer = AttributeContainer()
        attributeContainer.font = UIFont.boldSystemFont(ofSize: 15)
        config.attributedTitle = AttributedString("주변 식당 랜덤 추천하기", attributes: attributeContainer)
        config.baseForegroundColor = .black
        config.contentInsets = .init(top: 12, leading: 0, bottom: 12, trailing: 0)
        
        let randomRecommendButton = UIButton()
        randomRecommendButton.configuration = config
        randomRecommendButton.backgroundColor = UIColor(named: "PrimaryColor")
        randomRecommendButton.layer.cornerRadius = 10
        randomRecommendButton.translatesAutoresizingMaskIntoConstraints = false
        return randomRecommendButton
    }()
    private lazy var restaurantContainer = {
        let restaurantContainer = UIView()
        restaurantContainer.layer.cornerRadius = 10
        restaurantContainer.layer.masksToBounds = true
        restaurantContainer.backgroundColor = UIColor(named: "PrimaryColor")
        restaurantContainer.translatesAutoresizingMaskIntoConstraints = false
        restaurantContainer.isHidden = true
        return restaurantContainer
    }()
    private lazy var restaurantNameLabel = {
        let restaurantNameLabel = UILabel()
        restaurantNameLabel.text = "스톤504"
        restaurantNameLabel.textColor = .black
        restaurantNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        restaurantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return restaurantNameLabel
    }()
    private lazy var restaurantImageView = {
        let menuImageView = UIImageView()
        menuImageView.image = UIImage(named: "SampleRestaurantImage")
        menuImageView.layer.cornerRadius = 10
        menuImageView.layer.masksToBounds = true
        menuImageView.translatesAutoresizingMaskIntoConstraints = false
        return menuImageView
    }()
    private lazy var noImageLabel = {
        let noImageLabel = UILabel()
        noImageLabel.text = "No Image for This Restaurant"
        noImageLabel.textAlignment = .center
        noImageLabel.textColor = .gray
        noImageLabel.font = .systemFont(ofSize: 20, weight: .medium)
        noImageLabel.translatesAutoresizingMaskIntoConstraints = false
        noImageLabel.isHidden = true
        return noImageLabel
    }()
    private lazy var ratingLabel = {
        let ratingLabel = UILabel()
        ratingLabel.text = "평점 : 4.1"
        ratingLabel.textColor = .black
        ratingLabel.font = .systemFont(ofSize: 15, weight: .medium)
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
                    star.widthAnchor.constraint(equalToConstant: 16),
                    star.heightAnchor.constraint(equalToConstant: 16)
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
        restaurantDistanceLabel.font = .systemFont(ofSize: 15, weight: .medium)
        restaurantDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        return restaurantDistanceLabel
    }()
    private lazy var restaurantInfoButton = {
        let restaurantInfoButton = UIButton()
        restaurantInfoButton.setTitle("식당 정보 보기", for: .normal)
        restaurantInfoButton.setTitleColor(.systemBlue, for: .normal)
        restaurantInfoButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        restaurantInfoButton.translatesAutoresizingMaskIntoConstraints = false
        return restaurantInfoButton
    }()
    private lazy var recommendAgainButton = {
        var config = UIButton.Configuration.plain()
        
        var attributeContainer = AttributeContainer()
        attributeContainer.font = UIFont.boldSystemFont(ofSize: 15)
        config.attributedTitle = AttributedString("다시하기", attributes: attributeContainer)
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "arrow.clockwise")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        )
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
        
        let randomRecommendButton = UIButton()
        randomRecommendButton.configuration = config
        randomRecommendButton.backgroundColor = .black
        randomRecommendButton.layer.cornerRadius = 10
        randomRecommendButton.translatesAutoresizingMaskIntoConstraints = false
        return randomRecommendButton
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
    private lazy var indicatorContainer = {
        let indicatorContainer = UIView()
        indicatorContainer.layer.cornerRadius = 10
        indicatorContainer.layer.masksToBounds = true
        indicatorContainer.backgroundColor = UIColor(named: "PrimaryColor")
        indicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        indicatorContainer.isHidden = true
        return indicatorContainer
    }()
    private lazy var indicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.color = .gray
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    private lazy var indicatorLabel = {
        let indicatorLabel = UILabel()
        indicatorLabel.text = "주위 식당 정보를 불러오고 있습니다\n이 작업은 처음에만 몇 초정도 소요됩니다"
        indicatorLabel.numberOfLines = 2
        indicatorLabel.textAlignment = .center
        indicatorLabel.textColor = .gray
        indicatorLabel.font = .systemFont(ofSize: 15, weight: .medium)
        indicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        return indicatorLabel
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        bindSlider()
        
        bindViewModel()
        
        setButtonActions()
        
        setupUI()
    }
    
    //MARK: 버튼 액션 함수
    private func setButtonActions() {
        // Button Actions
        currentLocationButton.addAction(UIAction { [weak self] _ in
            self?.randomRecommendViewModel.fetchCurrentLocationAndAddress()
        }, for: .touchUpInside)
        
        searchButton.addAction(UIAction { [weak self] _ in
            let searchPageViewController = SearchPageViewController()
            searchPageViewController.locationViewModelDelegate = self?.randomRecommendViewModel.locationViewModel
            searchPageViewController.randomRecommendViewModelDelegate = self?.randomRecommendViewModel
            self?.present(searchPageViewController, animated: true, completion: nil)
        }, for: .touchUpInside)
        
        randomRecommendButton.addAction(UIAction { [weak self] _ in
            self?.randomRecommendViewModel.fetchNearbyRestaurants()
        }, for: .touchUpInside)
        
        restaurantInfoButton.addAction(UIAction { [weak self] _ in
            guard let placeDetail = self?.randomRecommendViewModel.restaurantDetail else { return }
            let webViewController = WebViewController(urlString: placeDetail.url)
            self?.present(webViewController, animated: true, completion: nil)
            
        }, for: .touchUpInside)
        
        recommendAgainButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            if self.randomRecommendViewModel.isConditionChanged {
                self.randomRecommendViewModel.fetchNearbyRestaurants()
            } else {
                self.randomRecommendViewModel.getRandomRestaurantDetail()
            }
        }, for: .touchUpInside)
        
        directionsButton.addAction(UIAction { _ in
            print("길찾기")
        }, for: .touchUpInside)
    }
    
    //MARK: 슬라이더 바인딩 함수
    private func bindSlider() {
        // Slider 값 변경에 따른 업데이트
        distanceSlider.controlEventPublisher(for: [.touchUpInside, .touchUpOutside])
            .map { [weak self] _ -> Float in
                guard let self = self else { return 0.5 }
                return self.mapToAllowedValue(value: self.distanceSlider.value)
            }
            .sink { [weak self] allowedValue in
                guard let self = self else { return }
                distanceSlider.setValue(allowedValue, animated: false)
                self.randomRecommendViewModel.maximumDistance = mapToDistance(value: allowedValue)
                self.randomRecommendViewModel.isConditionChanged = true
            }
            .store(in: &cancellables)
        distanceSlider.valuePublisher
            .map { [weak self] value -> Float in
                guard let self = self else { return 0.5 }
                return self.mapToAllowedValue(value: value)
            }
            .sink { [weak self] allowedValue in
                guard let self = self else { return }
                let tempMaximumDistance = mapToDistance(value: allowedValue)
                distanceSettingLabel.text = "최대 거리 설정 (\(tempMaximumDistance)m)"
            }
            .store(in: &cancellables)
    }
    
    //MARK: 뷰모델 바인딩 함수
    private func bindViewModel() {
        // 주소 업데이트 바인딩
        randomRecommendViewModel.$currentAddress
            .sink { [weak self] address in
                if let address = address {
                    print("Current Address: \(address)")
                    
                    DispatchQueue.main.async {
                        self?.placeLabel.text = address
                    }
                }
            }
            .store(in: &cancellables)
        
        // 식당 상세 정보 바인딩
        randomRecommendViewModel.$restaurantDetail
            .sink { [weak self] restaurantDetail in
                if let restaurantDetail = restaurantDetail {
                    DispatchQueue.main.async {
                        self?.restaurantNameLabel.text = restaurantDetail.name
                        self?.ratingLabel.text = "평점 : \(restaurantDetail.rating ?? 0.0) (\(restaurantDetail.user_ratings_total ?? 0))"
                        self?.updateRatingStars(rating: restaurantDetail.rating ?? 0.0)
                        self?.restaurantDistanceLabel.text = "거리 : \(self?.randomRecommendViewModel.getDistanceBetween() ?? 0) m"
                    }
                }
            }
            .store(in: &cancellables)
        
        // Photo URL 바인딩
        randomRecommendViewModel.$photoURL
            .sink { [weak self] photoURL in
                let photoImage = UIImage(systemName: "photo")?
                    .withTintColor(.gray, renderingMode: .alwaysOriginal)
                let resizedImage = self?.resizeImage(image: photoImage, to: CGSize(width: 100, height: 100))
                let paddedImage = self?.addPaddingToImage(image: resizedImage, paddingSize: 100, paddingColor: .white)
                
                if let photoURL = photoURL {
                    // 이미지 정보가 있는 식당일 경우
                    DispatchQueue.main.async {
                        self?.restaurantImageView.kf.setImage(with: photoURL, placeholder: paddedImage, options: [
                            .cacheOriginalImage,
                        ])
                        self?.noImageLabel.isHidden = true
                    }
                } else {
                    // 이미지 정보가 없는 식당일 경우
                    DispatchQueue.main.async {
                        self?.restaurantImageView.image = paddedImage
                        self?.noImageLabel.isHidden = false
                    }
                }
            }
            .store(in: &cancellables)
        
        // isFetching 바인딩
        randomRecommendViewModel.$isFetching
            .sink { [weak self] isFetching in
                if isFetching {
                    self?.randomRecommendButton.isHidden = true
                    self?.restaurantContainer.isHidden = true
                    self?.indicatorContainer.isHidden = false
                    self?.indicatorView.startAnimating()
                } else {
                    if self?.randomRecommendButton.isHidden == true {
                        self?.restaurantContainer.isHidden = false
                        self?.indicatorContainer.isHidden = true
                        self?.indicatorView.stopAnimating()
                    }
                }
            }
            .store(in: &cancellables)
        
        // 에러 메시지 바인딩
        randomRecommendViewModel.$errorMessage
            .compactMap { $0 } // nil 값 제거
            .sink { errorMessage in
                if errorMessage == LocationServiceError.permissionDenied.errorDescription {
                    self.showPermissionDeniedAlert()
                } else if errorMessage == LocationServiceError.permissionRestricted.errorDescription {
                    self.showPermissionRestrictedAlert()
                } else {
                    print("Error: \(errorMessage)")
                }
            }
            .store(in: &cancellables)
        
    }
    
    //MARK: UI Setup 함수
    private func setupUI() {
        view.addSubview(titleImageView)
        view.addSubview(titleLabel)
        view.addSubview(separatorLine)
        view.addSubview(placeSettingLabel)
        view.addSubview(currentLocationButton)
        view.addSubview(placeContainer)
        placeContainer.addSubview(placeLabel)
        placeContainer.addSubview(searchButton)
        view.addSubview(distanceSettingLabel)
        view.addSubview(distanceContainer)
        distanceContainer.addSubview(distanceSlider)
        distanceContainer.addSubview(distanceLabelStack)
        view.addSubview(recommendRestaurantLabel)
        view.addSubview(randomRecommendButton)
        view.addSubview(restaurantContainer)
        restaurantContainer.addSubview(restaurantNameLabel)
        restaurantContainer.addSubview(restaurantImageView)
        restaurantContainer.addSubview(noImageLabel)
        restaurantContainer.addSubview(ratingLabel)
        restaurantContainer.addSubview(ratingStack)
        restaurantContainer.addSubview(restaurantDistanceLabel)
        restaurantContainer.addSubview(restaurantInfoButton)
        restaurantContainer.addSubview(recommendAgainButton)
        restaurantContainer.addSubview(directionsButton)
        view.addSubview(indicatorContainer)
        indicatorContainer.addSubview(indicatorView)
        indicatorContainer.addSubview(indicatorLabel)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            titleImageView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 3),
            titleImageView.widthAnchor.constraint(equalToConstant: 25),
            titleImageView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -3),
            
            titleLabel.leadingAnchor.constraint(equalTo: titleImageView.trailingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            
            separatorLine.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            separatorLine.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            separatorLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            placeSettingLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            placeSettingLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            
            currentLocationButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            currentLocationButton.bottomAnchor.constraint(equalTo: placeSettingLabel.bottomAnchor, constant: 7),
            
            placeContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            placeContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            placeContainer.topAnchor.constraint(equalTo: placeSettingLabel.bottomAnchor, constant: 5),
            
            placeLabel.topAnchor.constraint(equalTo: placeContainer.topAnchor, constant: 10),
            placeLabel.leadingAnchor.constraint(equalTo: placeContainer.leadingAnchor, constant: 15),
            placeLabel.bottomAnchor.constraint(equalTo: placeContainer.bottomAnchor, constant: -10),
            
            searchButton.topAnchor.constraint(equalTo: placeLabel.topAnchor),
            searchButton.leadingAnchor.constraint(equalTo: placeLabel.trailingAnchor, constant: 15),
            searchButton.trailingAnchor.constraint(equalTo: placeContainer.trailingAnchor, constant: -15),
            searchButton.bottomAnchor.constraint(equalTo: placeLabel.bottomAnchor),
            
            distanceSettingLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            distanceSettingLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            distanceSettingLabel.topAnchor.constraint(equalTo: placeContainer.bottomAnchor, constant: 10),
            
            distanceContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            distanceContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            distanceContainer.topAnchor.constraint(equalTo: distanceSettingLabel.bottomAnchor, constant: 5),
            
            distanceSlider.leadingAnchor.constraint(equalTo: distanceContainer.leadingAnchor, constant: 10),
            distanceSlider.trailingAnchor.constraint(equalTo: distanceContainer.trailingAnchor, constant: -10),
            distanceSlider.topAnchor.constraint(equalTo: distanceContainer.topAnchor, constant: 10),
            
            distanceLabelStack.leadingAnchor.constraint(equalTo: distanceContainer.leadingAnchor, constant: 10),
            distanceLabelStack.trailingAnchor.constraint(equalTo: distanceContainer.trailingAnchor, constant: -10),
            distanceLabelStack.topAnchor.constraint(equalTo: distanceSlider.bottomAnchor, constant: 10),
            distanceLabelStack.bottomAnchor.constraint(equalTo: distanceContainer.bottomAnchor, constant: -10),
            
            recommendRestaurantLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            recommendRestaurantLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            recommendRestaurantLabel.topAnchor.constraint(equalTo: distanceContainer.bottomAnchor, constant: 20),
            
            randomRecommendButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            randomRecommendButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            randomRecommendButton.topAnchor.constraint(equalTo: recommendRestaurantLabel.bottomAnchor, constant: 10),
            
            restaurantContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            restaurantContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            restaurantContainer.topAnchor.constraint(equalTo: recommendRestaurantLabel.bottomAnchor, constant: 10),
            
            restaurantNameLabel.leadingAnchor.constraint(equalTo: restaurantContainer.leadingAnchor, constant: 20),
            restaurantNameLabel.trailingAnchor.constraint(equalTo: restaurantContainer.trailingAnchor, constant: -20),
            restaurantNameLabel.topAnchor.constraint(equalTo: restaurantContainer.topAnchor, constant: 12),
            
            restaurantImageView.leadingAnchor.constraint(equalTo: restaurantContainer.leadingAnchor, constant: 20),
            restaurantImageView.trailingAnchor.constraint(equalTo: restaurantContainer.trailingAnchor, constant: -20),
            restaurantImageView.topAnchor.constraint(equalTo: restaurantNameLabel.bottomAnchor, constant: 12),
            restaurantImageView.heightAnchor.constraint(equalToConstant: 200),
            
            noImageLabel.centerXAnchor.constraint(equalTo: restaurantContainer.centerXAnchor),
            noImageLabel.bottomAnchor.constraint(equalTo: restaurantImageView.bottomAnchor, constant: -20),
            
            ratingLabel.leadingAnchor.constraint(equalTo: restaurantContainer.leadingAnchor, constant: 20),
            ratingLabel.topAnchor.constraint(equalTo: restaurantImageView.bottomAnchor, constant: 12),
            
            ratingStack.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 5),
            ratingStack.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            
            restaurantDistanceLabel.trailingAnchor.constraint(equalTo: restaurantContainer.trailingAnchor, constant: -20),
            restaurantDistanceLabel.topAnchor.constraint(equalTo: restaurantImageView.bottomAnchor, constant: 12),
            
            restaurantInfoButton.leadingAnchor.constraint(equalTo: restaurantContainer.leadingAnchor, constant: 20),
            restaurantInfoButton.topAnchor.constraint(equalTo: restaurantDistanceLabel.bottomAnchor),
            
            recommendAgainButton.leadingAnchor.constraint(equalTo: restaurantContainer.leadingAnchor, constant: 20),
            recommendAgainButton.trailingAnchor.constraint(equalTo: restaurantContainer.centerXAnchor, constant: -10),
            recommendAgainButton.topAnchor.constraint(equalTo: restaurantInfoButton.bottomAnchor, constant: 8),
            recommendAgainButton.bottomAnchor.constraint(equalTo: restaurantContainer.bottomAnchor, constant: -12),
            
            directionsButton.leadingAnchor.constraint(equalTo: restaurantContainer.centerXAnchor, constant: 10),
            directionsButton.trailingAnchor.constraint(equalTo: restaurantContainer.trailingAnchor, constant: -20),
            directionsButton.topAnchor.constraint(equalTo: recommendAgainButton.topAnchor),
            directionsButton.bottomAnchor.constraint(equalTo: recommendAgainButton.bottomAnchor),
            
            indicatorContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            indicatorContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            indicatorContainer.topAnchor.constraint(equalTo: recommendRestaurantLabel.bottomAnchor, constant: 10),
            indicatorContainer.heightAnchor.constraint(equalToConstant: 366.6666666666667),
            
            indicatorView.centerXAnchor.constraint(equalTo: indicatorContainer.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: indicatorContainer.centerYAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 150),
            indicatorView.heightAnchor.constraint(equalToConstant: 150),
            
            indicatorLabel.centerXAnchor.constraint(equalTo: indicatorContainer.centerXAnchor),
            indicatorLabel.bottomAnchor.constraint(equalTo: indicatorContainer.bottomAnchor, constant: -20),
        ])
    }
    
    //MARK: UI 업데이트 함수
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
    
    //MARK: Alert 함수
    private func showPermissionDeniedAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "위치 서비스 권한 필요",
                message: self.randomRecommendViewModel.errorMessage,
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
                message: self.randomRecommendViewModel.errorMessage,
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
                message: self.randomRecommendViewModel.errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "닫기", style: .default))
            
            self.present(alert, animated: true)
        }
    }
    
    //MARK: UI 보조 함수
    // Slider 특정 단위값에서만 세팅되도록 하는 함수
    private func mapToAllowedValue(value: Float) -> Float {
        guard let closestValue = randomRecommendViewModel.allowedValues.min(by: { abs($0 - value) < abs($1 - value) }) else {
            return value
        }
        return closestValue
    }
    
    // Slider 값 거리로 변환 함수
    private func mapToDistance(value: Float) -> Int {
        let index = randomRecommendViewModel.allowedValues.firstIndex(of: value) ?? randomRecommendViewModel.allowedValues.count / 2
        return randomRecommendViewModel.allowedDistances[index]
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
