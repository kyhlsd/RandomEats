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
    
    private lazy var titleLabel = {
        let titleLabel = UILabel()
        titleLabel.text = "RandomEats"
        titleLabel.textColor = UIColor(named: "PrimaryColor")
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
        placeSettingLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeSettingLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeSettingLabel
    }()
    private lazy var currentLocationButton = {
        let currentLocationButton = UIButton()
        currentLocationButton.setTitle("현재 위치로", for: .normal)
        currentLocationButton.setTitleColor(.systemBlue, for: .normal)
        currentLocationButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
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
        placeLabel.backgroundColor = UIColor(named: "SecondaryColor")
        
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeLabel
    }()
    private lazy var distanceSettingLabel = {
        let distanceSettingLabel = UILabel()
        distanceSettingLabel.text = "최대 거리 설정 (\(maximumDistance)m)"
        distanceSettingLabel.textColor = .black
        distanceSettingLabel.font = .systemFont(ofSize: 12, weight: .medium)
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        distanceSlider.controlEventPublisher(for: [.touchUpInside, .touchUpOutside])
            .map { [weak self] _ -> Float in
                guard let self = self else { return 0.5 }
                return self.mapToAllowedValue(value: self.distanceSlider.value)
            }
            .sink { [weak self] allowedValue in
                guard let self = self else { return }
                distanceSlider.setValue(allowedValue, animated: false)
                maximumDistance = mapToDistance(value: allowedValue)
                distanceSettingLabel.text = "최대 거리 설정 (\(maximumDistance)m)"
            }
            .store(in: &cancellables)
        
        currentLocationButton.addAction(UIAction { [weak self] _ in
            print("현재 위치로 설정하기")
            self?.placeLabel.text = "현재 위치로 설정됨"
        }, for: .touchUpInside)
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(separatorLine)
        view.addSubview(placeSettingLabel)
        view.addSubview(currentLocationButton)
        view.addSubview(placeContainer)
        placeContainer.addSubview(placeLabel)
        view.addSubview(distanceSettingLabel)
        view.addSubview(distanceContainer)
        distanceContainer.addSubview(distanceSlider)
        distanceContainer.addSubview(distanceLabelStack)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            
            separatorLine.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            separatorLine.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            separatorLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            placeSettingLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            placeSettingLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            
            currentLocationButton.leadingAnchor.constraint(equalTo: placeSettingLabel.trailingAnchor, constant: 10),
            currentLocationButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            currentLocationButton.topAnchor.constraint(equalTo: placeSettingLabel.topAnchor),
            currentLocationButton.bottomAnchor.constraint(equalTo: placeSettingLabel.bottomAnchor),
            
            placeContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            placeContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            placeContainer.topAnchor.constraint(equalTo: placeSettingLabel.bottomAnchor, constant: 10),
            
            placeLabel.topAnchor.constraint(equalTo: placeContainer.topAnchor, constant: 10),
            placeLabel.leadingAnchor.constraint(equalTo: placeContainer.leadingAnchor, constant: 15),
            placeLabel.trailingAnchor.constraint(equalTo: placeContainer.trailingAnchor, constant: -15),
            placeLabel.bottomAnchor.constraint(equalTo: placeContainer.bottomAnchor, constant: -10),
            
            distanceSettingLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            distanceSettingLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            distanceSettingLabel.topAnchor.constraint(equalTo: placeContainer.bottomAnchor, constant: 10),
            
            distanceContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            distanceContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            distanceContainer.topAnchor.constraint(equalTo: distanceSettingLabel.bottomAnchor, constant: 10),
            
            distanceSlider.leadingAnchor.constraint(equalTo: distanceContainer.leadingAnchor, constant: 10),
            distanceSlider.trailingAnchor.constraint(equalTo: distanceContainer.trailingAnchor, constant: -10),
            distanceSlider.topAnchor.constraint(equalTo: distanceContainer.topAnchor, constant: 10),
            
            distanceLabelStack.leadingAnchor.constraint(equalTo: distanceContainer.leadingAnchor, constant: 10),
            distanceLabelStack.trailingAnchor.constraint(equalTo: distanceContainer.trailingAnchor, constant: -10),
            distanceLabelStack.topAnchor.constraint(equalTo: distanceSlider.bottomAnchor, constant: 10),
            distanceLabelStack.bottomAnchor.constraint(equalTo: distanceContainer.bottomAnchor, constant: -10),
        ])
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
