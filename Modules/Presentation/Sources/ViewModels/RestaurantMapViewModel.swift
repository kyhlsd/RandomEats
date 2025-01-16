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
    private let reverseGeocodingViewModel: ReverseGeocodingViewModel
    private let locationUseCase: LocationUseCaseProtocol
    public weak var delegate: CenterMapBetweenLocationsDelegate?

    public init(locationViewModel: LocationViewModel, reverseGeocodingViewModel: ReverseGeocodingViewModel, locationUseCase: LocationUseCaseProtocol) {
        self.locationViewModel = locationViewModel
        self.reverseGeocodingViewModel = reverseGeocodingViewModel
        self.locationUseCase = locationUseCase
        bindViewModels()
    }
    
    private func bindViewModels() {
        // 위치 업데이트 바인딩
        locationViewModel.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.setLocation = location
            }
            .store(in: &cancellables)
    }
    
    // 위치를 설정하는 경우
    func fetchCurrentLocationAndAddressForSet() {
        locationViewModel.fetchCurrentLocation()
    }
    
    // 지도에서 현재 위치를 표기할 때
    func fetchCurrentLocation() {
        locationUseCase.getCurrentLocation()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case LocationServiceError.permissionDenied:
                        self?.errorMessage = LocationServiceError.permissionDenied.errorDescription
                    case LocationServiceError.permissionRestricted:
                        self?.errorMessage = LocationServiceError.permissionRestricted.errorDescription
                    default:
                        self?.errorMessage = LocationServiceError.unknownError.errorDescription
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] location in
                self?.currentLocation = location
                self?.delegate?.centerMapBetweenLocations()
            })
            .store(in: &cancellables)
    }
    
    func getDistanceBetween() -> Int? {
        guard let currentLocation = currentLocation else {
            print("currentLocation is nil")
            return nil
        }
        guard let destinationLocation = setLocation else {
            print("setLocation is nil")
            return nil
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
    
    // 평균 위도, 경도 구하기
    func getAverageLocation() -> Location? {
        guard let currentLocation = currentLocation else {
            print("currentLocation is nil")
            return nil
        }
        guard let destinationLocation = setLocation else {
            print("setLocation is nil")
            return nil
        }
        let averageLatitude = (currentLocation.getLatitude() + destinationLocation.getLatitude()) / 2
        let averageLongitude = (currentLocation.getLongitude() + destinationLocation.getLongitude()) / 2
        let averageLocation = Location(latitude: averageLatitude, longitude: averageLongitude)
        
        return averageLocation
    }
}

extension RestaurantMapViewModel: SetAddressWithSearchedResultDelegate {
    func setAddressWithSearchedResult(searchedAddress: String) {
        self.reverseGeocodingViewModel.address = searchedAddress
    }
}
