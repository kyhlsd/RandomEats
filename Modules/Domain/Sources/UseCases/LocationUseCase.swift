//
//  LocationUseCase.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import Foundation
import Combine

public protocol LocationUseCaseProtocol {
    func getCurrentLocation() -> AnyPublisher<Location, Error>
    func fetchPreviousLocation() -> AnyPublisher<Location, Error>
    func updateCoreDataLocation(location: Location)
}

public class LocationUseCase: LocationUseCaseProtocol {
    private let locationRepository: LocationRepositoryProtocol

    public init(locationRepository: LocationRepositoryProtocol) {
        self.locationRepository = locationRepository
    }

    public func getCurrentLocation() -> AnyPublisher<Location, Error> {
        return locationRepository.fetchCurrentLocation()
    }
    
    public func fetchPreviousLocation() -> AnyPublisher<Location, Error> {
        return locationRepository.fetchPreviousLocation()
    }
    
    public func updateCoreDataLocation(location: Location) {
        locationRepository.updateCoreDataLocation(location: location)
    }
}
