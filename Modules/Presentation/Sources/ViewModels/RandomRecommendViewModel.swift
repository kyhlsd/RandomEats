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

protocol SetAddressWithSearchedResultDelegate: AnyObject {
    func setAddressWithSearchedResult(searchedAddress: String)
}

public class RandomRecommendViewModel {
    let locationViewModel: LocationViewModel
    let reverseGeocodingViewModel: ReverseGeocodingViewModel
    let searchRestaurantViewModel: SearchRestaurantViewModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published var errorMessage: String?
    @Published var restaurantDetail: PlaceDetail?
    @Published var photoURL: URL?
    @Published var isFetching = false
    @Published var shouldShowEmptyContainer = false
    
    let allowedValues: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]
    let allowedDistances: [Int] = [100, 200, 300, 400, 500]
    private var restaurants = [PlaceForNearbySearch]()
    var initialStateForEmptyList = true
    
    public init(locationViewModel: LocationViewModel, reverseGeocodingViewModel: ReverseGeocodingViewModel, searchRestaurantViewModel: SearchRestaurantViewModel) {
        self.locationViewModel = locationViewModel
        self.reverseGeocodingViewModel = reverseGeocodingViewModel
        self.searchRestaurantViewModel = searchRestaurantViewModel
        bindViewModels()
    }
    
    private func bindViewModels() {
        // 위치 업데이트 바인딩
        locationViewModel.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                if let isAddressUpdateNeeded = self?.locationViewModel.isAddressUpdateNeeded, isAddressUpdateNeeded {
                    self?.fetchAddress(for: location)
                } else {
                    self?.locationViewModel.isAddressUpdateNeeded = true
                }
                self?.searchRestaurantViewModel.isConditionChanged = true
                self?.locationViewModel.updateCoreDataLocation(location: location)
            }
            .store(in: &cancellables)
        
        // 위치 에러 메세지 바인딩
        locationViewModel.$errorMessage
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.errorMessage = errorMessage
                }
            }
            .store(in: &cancellables)
        
        // 주소 변환 결과 바인딩
        reverseGeocodingViewModel.$address
            .compactMap { $0 }
            .sink { [weak self] address in
                self?.reverseGeocodingViewModel.updateCoreDataAddress(address: address)
            }
            .store(in: &cancellables)
        
        // 주소 변환 에러 메세지 바인딩
        reverseGeocodingViewModel.$errorMessage
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.errorMessage = errorMessage
                }
            }
            .store(in: &cancellables)
        
        // 주위 식당 가져오기 결과 바인딩
        searchRestaurantViewModel.$restaurants
            .sink { [weak self] restaurants in
                if let restaurants = restaurants {
                    self?.restaurants = restaurants
                }
                if let initialStateForEmptyList =  self?.initialStateForEmptyList, initialStateForEmptyList {
                    self?.initialStateForEmptyList = false
                } else {
                    self?.getRandomRestaurantDetail()
                }
            }
            .store(in: &cancellables)
        
        // 식당 정보 바인딩
        searchRestaurantViewModel.$restaurantDetail
            .sink { [weak self] restaurantDetail in
                if let restaurantDetail = restaurantDetail {
                    self?.restaurantDetail = restaurantDetail
                    self?.isFetching = false
                }
            }
            .store(in: &cancellables)
        
        searchRestaurantViewModel.$photoURL
            .sink { [weak self] photoURL in
                    self?.photoURL = photoURL
            }
            .store(in: &cancellables)
        
        // 주위 식당, 식당 정보, 사진 URL 가져오기 에러 메세지 바인딩
        searchRestaurantViewModel.$errorMessage
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.errorMessage = errorMessage
                }
            }
            .store(in: &cancellables)
    }
    
    // 이전 위치, 주소 정보 가져오기
    func fetchPreviousLocationAddress() {
        locationViewModel.fetchPreviousLocation()
        reverseGeocodingViewModel.fetchPreviousAddress()
    }
    
    // 현재 위치 가져오기 시작
    func fetchCurrentLocationAndAddress() {
        locationViewModel.fetchCurrentLocation()
    }
    
    // ReverseGeocodingViewModel을 사용해 주소 변환
    private func fetchAddress(for location: Location) {
        reverseGeocodingViewModel.fetchAddress(for: location)
    }
    
    //주변 식당 정보 가져오기
    func fetchNearbyRestaurants() {
        if let location = locationViewModel.location {
            isFetching = true
            searchRestaurantViewModel.fetchNearbyRestaurant(for: location, maximumDistance: searchRestaurantViewModel.maximumDistance)
            searchRestaurantViewModel.isConditionChanged = false
        }
    }
    
    // 식당 상세 정보 가져오기
    func getRandomRestaurantDetail() {
        if restaurants.isEmpty {
            self.shouldShowEmptyContainer = true
            return
        } else {
            self.shouldShowEmptyContainer = false
        }
        guard let randomPickedId = restaurants.randomElement()?.place_id else {
            print("Random Pick Id 오류")
            return
        }
        searchRestaurantViewModel.fetchRestaurantDetail(placeId: randomPickedId)
    }
    
    // 위치, 경도 값으로 거리 계산 (Haversine 공식)
    func getDistanceBetween() -> Int {
        guard let currentLocation = locationViewModel.location, let destinationLocation = restaurantDetail?.geometry.location else {
            print("Location is nil")
            return 0
        }
        
        let earthRadius = 6_371_000.0
        
        let currentLat = currentLocation.getLatitude()
        let currentLng = currentLocation.getLongitude()
        let destinationLat = destinationLocation.getLatitude()
        let destinationLng = destinationLocation.getLongitude()
        
        let currentLatRad = currentLat * .pi / 180
        let destinationLatRad = destinationLat * .pi / 180
        let deltaLat = (destinationLat - currentLat) * .pi / 180
        let deltaLng = (destinationLng - currentLng) * .pi / 180
        
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) + cos(currentLatRad) * cos(destinationLatRad) * sin(deltaLng / 2) * sin(deltaLng / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        let distance = Int(earthRadius * c)
        
        return distance
    }
}

extension RandomRecommendViewModel: SetAddressWithSearchedResultDelegate {
    func setAddressWithSearchedResult(searchedAddress: String) {
        self.reverseGeocodingViewModel.address = searchedAddress
    }
}
