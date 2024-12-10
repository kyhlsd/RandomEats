//
//  RandomRecommendViewController.swift
//  Data
//
//  Created by 김영훈 on 11/28/24.
//

import UIKit
import Combine
import CombineCocoa

public class RandomRecommendViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private let allowedValues: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]
    private let allowedDistances: [Int] = [100, 200, 300, 400, 500]
    private var maximumDistance = 300
    
//    private var locationViewModel: LocationViewModel
//    private var reverseGeocodingViewModel: ReverseGeocodingViewModel
    private var randomRecommendViewModel: RandomRecommendViewModel
    
//    public init(locationViewModel: LocationViewModel, reverseGeocodingViewModel: ReverseGeocodingViewModel) {
//        self.locationViewModel = locationViewModel
//        self.reverseGeocodingViewModel = reverseGeocodingViewModel
//        super.init(nibName: nil, bundle: nil)
//    }
    
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
        distanceSettingLabel.text = "최대 거리 설정 (\(maximumDistance)m)"
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
        restaurantNameLabel.text = "스톤504 / 양식"
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        // Slider 값 변경에 따른 UI 업데이트
        distanceSlider.controlEventPublisher(for: [.touchUpInside, .touchUpOutside])
            .map { [weak self] _ -> Float in
                guard let self = self else { return 0.5 }
                return self.mapToAllowedValue(value: self.distanceSlider.value)
            }
            .sink { [weak self] allowedValue in
                guard let self = self else { return }
                distanceSlider.setValue(allowedValue, animated: false)
            }
            .store(in: &cancellables)
        distanceSlider.valuePublisher
            .map { [weak self] value -> Float in
                guard let self = self else { return 0.5 }
                return self.mapToAllowedValue(value: value)
            }
            .sink { [weak self] allowedValue in
                guard let self = self else { return }
                maximumDistance = mapToDistance(value: allowedValue)
                distanceSettingLabel.text = "최대 거리 설정 (\(maximumDistance)m)"
            }
            .store(in: &cancellables)
        
//        bindLocationViewModel()
        bindViewModel()
        
        // Button Actions
        currentLocationButton.addAction(UIAction { [weak self] _ in
            print("현재 위치로 설정하기")
//            self?.locationViewModel.fetchCurrentLocation()
            self?.randomRecommendViewModel.fetchCurrentLocationAndAddress()
//            self?.placeLabel.text = "현재 위치로 설정됨"
        }, for: .touchUpInside)
        
        searchButton.addAction(UIAction { _ in
            print("위치 검색하기")
        }, for: .touchUpInside)
        
        randomRecommendButton.addAction(UIAction { [weak self] _ in
            self?.randomRecommendViewModel.fetchNearbyRestaurants()
            self?.randomRecommendButton.isHidden = true
            self?.restaurantContainer.isHidden = false
        }, for: .touchUpInside)
        
        restaurantInfoButton.addAction(UIAction { [weak self] _ in
            let webViewController = WebViewController()
            self?.present(webViewController, animated: true, completion: nil)
        }, for: .touchUpInside)
        
        recommendAgainButton.addAction(UIAction { _ in
            print("다시하기")
        }, for: .touchUpInside)
        
        directionsButton.addAction(UIAction { _ in
            print("길찾기")
        }, for: .touchUpInside)
        
        setupUI()
    }
    
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
        restaurantContainer.addSubview(ratingLabel)
        restaurantContainer.addSubview(ratingStack)
        restaurantContainer.addSubview(restaurantDistanceLabel)
        restaurantContainer.addSubview(restaurantInfoButton)
        restaurantContainer.addSubview(recommendAgainButton)
        restaurantContainer.addSubview(directionsButton)
        
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
        ])
    }
    
//    private func bindLocationViewModel() {
//        locationViewModel.$location
//            .sink { location in
//                if let location = location {
//                    print(location)
//                }
//            }
//            .store(in: &cancellables)
//        locationViewModel.$errorMessage
//            .sink { errorMessage in
//                if let errorMessage = errorMessage {
//                    print(errorMessage)
//                }
//            }
//            .store(in: &cancellables)
//    }
    
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
        
        // 에러 메시지 바인딩
        randomRecommendViewModel.$errorMessage
            .sink { errorMessage in
                if let errorMessage = errorMessage {
                    print("Error: \(errorMessage)")
                }
            }
            .store(in: &cancellables)
        }
    
    private func mapToAllowedValue(value: Float) -> Float {
        guard let closestValue = allowedValues.min(by: { abs($0 - value) < abs($1 - value) }) else {
            return value
        }
        return closestValue
    }
    
    private func mapToDistance(value: Float) -> Int {
        let index = allowedValues.firstIndex(of: value) ?? allowedValues.count / 2
        return allowedDistances[index]
    }
}
