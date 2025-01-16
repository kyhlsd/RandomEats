//
//  RestaurantMapViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 1/17/25.
//

import Foundation
import Combine
import Domain

public class RestaurantMapViewModel {
    let allowedDistances = [100, 200, 300, 400, 500]
    var currentLocation: Location?
    var bestRestaurants: [PlaceDetail] = [PlaceDetail(name: "식당 이름", geometry: PlaceDetail.Geometry(location: Location(latitude: 37.575, longitude: 126.989)), url: "https://www.google.com", rating: 4.1, user_ratings_total: 5, photos: nil), PlaceDetail(name: "식당 이름2", geometry: PlaceDetail.Geometry(location: Location(latitude: 37.576, longitude: 126.99)), url: "https://www.naver.com", rating: 4.3, user_ratings_total: 2, photos: nil)]
    var selectedRestaurantIndex: Int? = nil
    private var cancellables = Set<AnyCancellable>()
    var shouldUpdateCurrentLocation = false
    
    @Published var setLocation: Location?
    @Published var errorMessage: String?
    
    let locationViewModel: LocationViewModel

    public init(locationViewModel: LocationViewModel, reverseGeocodingViewModel: ReverseGeocodingViewModel) {
        self.locationViewModel = locationViewModel
        bindViewModels()
    }
    
    private func bindViewModels() {
        // 위치 업데이트 바인딩
        locationViewModel.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.setLocation = location
                self?.locationViewModel.updateCoreDataLocation(location: location)
            }
            .store(in: &cancellables)
    }
    
    // 현재 위치 가져오기 시작
    func fetchCurrentLocationAndAddress() {
        locationViewModel.fetchCurrentLocation()
    }
    
}
