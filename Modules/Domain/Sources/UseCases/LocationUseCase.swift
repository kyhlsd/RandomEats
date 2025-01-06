//
//  LocationUseCase.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import Foundation
import Combine

public protocol LocationUseCaseProtocol {
    func getCurrentLocation() async throws -> Location
}

public class LocationUseCase: LocationUseCaseProtocol {
    private let locationRepository: LocationRepositoryProtocol

    public init(locationRepository: LocationRepositoryProtocol) {
        self.locationRepository = locationRepository
    }

    public func getCurrentLocation() async throws -> Location {
        return try await locationRepository.fetchCurrentLocation()
    }
    
    public func fetchPreviousLocation() -> AnyPublisher<Location, Error> {
        return locationRepository.fetchPreviousLocation()
    }
    
    public func updateCoreDataLocation(location: Location) {
        locationRepository.updateCoreDataLocation(location: location)
    }
}
