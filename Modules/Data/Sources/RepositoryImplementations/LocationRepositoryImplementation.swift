//
//  LocationRepositoryImplementation.swift
//  Data
//
//  Created by 김영훈 on 12/6/24.
//

import Domain
import Combine

public class LocationRepositoryImplementation: LocationRepositoryProtocol {
    private let locationService: LocationServiceProtocol

    public init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
    }

    public func fetchCurrentLocation() -> AnyPublisher<Location, Error> {
        return locationService.fetchCurrentLocation()
    }
    
    public func fetchPreviousLocation() -> AnyPublisher<Location, any Error> {
        return locationService.fetchPreviousLocation()
    }
    
    public func updateCoreDataLocation(location: Location) {
        locationService.updateCoreDataLocation(location: location)
    }
}
