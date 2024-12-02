//
//  RandomRecommendViewController.swift
//  Data
//
//  Created by 김영훈 on 11/28/24.
//

import UIKit
import Combine

public class RandomRecommendViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var titleLabel = {
        let titleLabel = UILabel()
        titleLabel.text = "RandomEats"
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    private lazy var placeSettingLabel = {
        let placeSettingLabel = UILabel()
        placeSettingLabel.text = "위치 설정"
        placeSettingLabel.textColor = .black
        placeSettingLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeSettingLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeSettingLabel
    }()
    private lazy var placeLabel = {
        let placeLabel = UILabel()
        placeLabel.text = "숭실대학교"
        placeLabel.textColor = .black
        placeLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        placeLabel.backgroundColor = .systemGray
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeLabel
    }()
    private lazy var distanceSettingLabel = {
        let distanceSettingLabel = UILabel()
        distanceSettingLabel.text = "거리 설정"
        distanceSettingLabel.textColor = .black
        distanceSettingLabel.font = .systemFont(ofSize: 12, weight: .medium)
        distanceSettingLabel.translatesAutoresizingMaskIntoConstraints = false
        return distanceSettingLabel
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
        firstDistanceLabel.text = "300m"
        firstDistanceLabel.textColor = .black
        firstDistanceLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        
        let secondDistanceLabel = UILabel()
        secondDistanceLabel.text = "500m"
        secondDistanceLabel.textColor = .black
        secondDistanceLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        
        let thirdDistanceLabel = UILabel()
        thirdDistanceLabel.text = "1,000m"
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

        view.backgroundColor = .white
        
        distanceSlider.publisher(for: \.value)
            .map { [weak self] currentValue -> Float in
                guard let self = self else { return 0.5 }
                return self.mapToAllowedValue(value: currentValue)
            }
            .sink { [weak self] allowedValue in
                self?.distanceSlider.setValue(allowedValue, animated: false)
            }
            .store(in: &self.cancellables)
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(placeSettingLabel)
        view.addSubview(placeLabel)
        view.addSubview(distanceSettingLabel)
        view.addSubview(distanceSlider)
        view.addSubview(distanceLabelStack)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            
            placeSettingLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            placeSettingLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            placeSettingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
            placeLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            placeLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            placeLabel.topAnchor.constraint(equalTo: placeSettingLabel.bottomAnchor, constant: 10),
            
            distanceSettingLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            distanceSettingLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            distanceSettingLabel.topAnchor.constraint(equalTo: placeLabel.bottomAnchor, constant: 10),
            
            distanceSlider.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            distanceSlider.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            distanceSlider.topAnchor.constraint(equalTo: distanceSettingLabel.bottomAnchor, constant: 10),
            
            distanceLabelStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            distanceLabelStack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            distanceLabelStack.topAnchor.constraint(equalTo: distanceSlider.bottomAnchor, constant: 10),
        ])
    }
    
    private func mapToAllowedValue(value: Float) -> Float {
        switch value {
        case 0.0..<0.25:
            print(0.0)
            return 0.0
        case 0.25..<0.75:
            print(0.5)
            return 0.5
        case 0.75...1:
            print(1.0)
            return 1.0
        default:
            print(0.0)
            return 0.5
        }
    }
}
