//
//  SearchPlaceViewModel.swift
//  Data
//
//  Created by 김영훈 on 12/18/24.
//

import Foundation
import Combine
import Domain
import Data
import CoreLocation

public class SearchPlaceViewModel {
    private let locationUseCase: LocationUseCaseProtocol
    private let searchPlaceUseCase: SearchPlaceUseCaseProtocol
    private let fetchCoordinatesUseCase: FetchCoordinatesUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()
    
    var selectedPrediction: PlacePrediction?
    
    @Published var placePredictions: [PlacePrediction]?
    @Published var placeLocation: Location?
    @Published var currentLocation: Location?
    @Published var errorMessage: String?
    
    // UseCase 주입
    public init(locationUseCase: LocationUseCaseProtocol, searchPlaceUseCase: SearchPlaceUseCaseProtocol, fetchCoordinatesUseCase: FetchCoordinatesUseCaseProtocol) {
        self.locationUseCase = locationUseCase
        self.searchPlaceUseCase = searchPlaceUseCase
        self.fetchCoordinatesUseCase = fetchCoordinatesUseCase
    }
    
    // 장소 자동 완성 응답 가져오기
    func fetchPlacePrediction(query: String) {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            placePredictions = []
        } else {
            searchPlaceUseCase.fetchPlacePrediction(query: query)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = "Failed to fetch nearby restaurants: \(error)"
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] placePredictions in
                    self?.placePredictions = placePredictions
                })
                .store(in: &cancellables)
        }
    }
    
    // placeId로 coordinates 가져오기
    func fetchCoordinates(placeId: String) {
        fetchCoordinatesUseCase.fetchCoordinates(placeId: placeId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch coordinates: \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] location in
                self?.placeLocation = location
            })
            .store(in: &cancellables)
    }
    
    // 현재 위치를 가져오는 함수
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
                    self?.errorMessage = "\(LocationServiceError.unknownError.errorDescription ?? "Failed to fetch location"): \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] location in
                self?.currentLocation = location
            })
            .store(in: &cancellables)
    }
    
    // 위치, 경도 값으로 거리 계산 (Haversine 공식)
    func getDistanceBetween() -> Int {
        guard let currentLocation = currentLocation, let destinationLocation = placeLocation else {
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
    
    // 평균 위도, 경도 구하기
    func getAverageLocation() -> Location? {
        guard let currentLocation = currentLocation, let destinationLocation = placeLocation else {
            print("Location is nil")
            return nil
        }
        let averageLatitude = (currentLocation.getLatitude() + destinationLocation.getLatitude()) / 2
        let averageLongitude = (currentLocation.getLongitude() + destinationLocation.getLongitude()) / 2
        let averageLocation = Location(latitude: averageLatitude, longitude: averageLongitude)
        
        return averageLocation
    }
}
