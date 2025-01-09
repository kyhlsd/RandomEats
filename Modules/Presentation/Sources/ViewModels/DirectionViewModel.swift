//
//  DirectionViewModel.swift
//  Data
//
//  Created by 김영훈 on 1/8/25.
//

import Foundation
import Domain
import Combine

public class DirectionViewModel {
    private let locationUseCase: LocationUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentLocation: Location?
    let originLocation: Location
    let destinationLocation: Location
    weak var delegate: CenterMapBetweenLocationsDelegate?
    
    @Published var errorMessage: String?
    
    init(originLocation: Location, destinationLocation: Location, locationUseCase: LocationUseCaseProtocol) {
        self.originLocation = originLocation
        self.destinationLocation = destinationLocation
        self.locationUseCase = locationUseCase
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
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] location in
                self?.currentLocation = location
                self?.delegate?.centerMapBetweenLocations()
            })
            .store(in: &cancellables)
    }
    
    // 평균 위도, 경도 구하기
    func getAverageLocation() -> Location {
        let averageLatitude = (originLocation.getLatitude() + destinationLocation.getLatitude()) / 2
        let averageLongitude = (originLocation.getLongitude() + destinationLocation.getLongitude()) / 2
        let averageLocation = Location(latitude: averageLatitude, longitude: averageLongitude)
        
        return averageLocation
    }
    
    // 두 지점 사이 거리 구하기
    func getDistanceBetween() -> Int {
        
        let earthRadius = 6_371_000.0
        
        let currentLat = originLocation.getLatitude()
        let currentLng = originLocation.getLongitude()
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
    
    // 현재 위치와 평균 지점 사이의 평균 위도, 경도 구하기
    func getAverageWithCurrentLocation() -> Location {
        let averageLocation = getAverageLocation()
        guard let currentLocation = currentLocation else {
            return averageLocation
        }
        
        let averageLatitude = (currentLocation.getLatitude() + averageLocation.getLatitude()) / 2
        let averageLongitude = (currentLocation.getLongitude() + averageLocation.getLongitude()) / 2
        let averageLocationWithCurrentLocation = Location(latitude: averageLatitude, longitude: averageLongitude)
        
        return averageLocationWithCurrentLocation
    }
    
    // 현재 위치와 평균 지점 사이 거리 구하기
    func getDistanceWithCurrentLocation() -> Int {
        guard let currentLocation = currentLocation else {
            return getDistanceBetween()
        }
        
        let averageLocation = getAverageLocation()
        
        let earthRadius = 6_371_000.0
        
        let currentLat = currentLocation.getLatitude()
        let currentLng = currentLocation.getLongitude()
        let destinationLat = averageLocation.getLatitude()
        let destinationLng = averageLocation.getLongitude()
        
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
