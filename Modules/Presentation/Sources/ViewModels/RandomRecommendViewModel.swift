//
//  RandomRecommendViewModel.swift
//  Domain
//
//  Created by 김영훈 on 12/9/24.
//

import Foundation
import Combine
import Domain
import Data

public class RandomRecommendViewModel {
    private let locationViewModel: LocationViewModel
    private let reverseGeocodingViewModel: ReverseGeocodingViewModel
    private let nearbyRestaurantViewModel: NearbyRestaurantViewModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published public var currentAddress: String?
    @Published public var errorMessage: String?
    private var maximumDistance = 300
    
    public init(locationViewModel: LocationViewModel, reverseGeocodingViewModel: ReverseGeocodingViewModel, nearbyRestaurantViewModel: NearbyRestaurantViewModel) {
        self.locationViewModel = locationViewModel
        self.reverseGeocodingViewModel = reverseGeocodingViewModel
        self.nearbyRestaurantViewModel = nearbyRestaurantViewModel
        bindViewModels()
    }
    
    private func bindViewModels() {
        // 위치 업데이트 바인딩
        locationViewModel.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.fetchAddress(for: location)
            }
            .store(in: &cancellables)
        
        // 위치 에러 메시지 바인딩
        locationViewModel.$errorMessage
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.errorMessage = errorMessage
                }
            }
            .store(in: &cancellables)
        
        // 주소 변환 에러 메시지 바인딩
        reverseGeocodingViewModel.$errorMessage
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.errorMessage = errorMessage
                }
            }
            .store(in: &cancellables)
        
        // 주소 변환 결과 바인딩
        reverseGeocodingViewModel.$address
            .sink { [weak self] address in
                if let address = address {
                    self?.currentAddress = address
                }
            }
            .store(in: &cancellables)
    }
    
    // 현재 위치 가져오기 시작
    public func fetchCurrentLocationAndAddress() {
        locationViewModel.fetchCurrentLocation()
    }
    
    // ReverseGeocodingViewModel을 사용해 주소 변환
    private func fetchAddress(for location: Location) {
        reverseGeocodingViewModel.fetchAddress(for: location)
    }
    
    //주변 식당 정보 가져오기
    public func fetchNearbyRestaurants() {
        if let location = locationViewModel.location {
            nearbyRestaurantViewModel.fetchNearbyRestaurant(for: location, maximumDistance: maximumDistance)
        }
    }
    
    public func setMaximumDistance(maximumDistance: Int) {
        self.maximumDistance = maximumDistance
    }
}
